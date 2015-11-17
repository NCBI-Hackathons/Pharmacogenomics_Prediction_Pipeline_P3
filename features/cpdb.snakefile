
# http://consensuspathdb.org/
# Click on download/data access
# In the dropdown for genes, choose Ensembl, then click on the green & red
# link-ish text to download the file. Save it as the input file to
# preprocess_cpdb rule.


# ----------------------------------------------------------------------------
# The Consensus Pathway Database file has a format like:
#
#   pathway    external_id    source    ensembl_ids
#
# Where `ensembl_ids` is a comma-separated list of Ensembl gene IDs. One row's
# fields look like:
#
#   pathway: PI3K-Akt signaling pathway - Homo sapiens (human)
#   external_id: path:hsa04151
#   source:  KEGG
#   ensembl_ids: ENSG00000160741,ENSG00000107175,ENSG00000198793...(more here)
#
# This rule converts the file into a two-column file like this:
#
#    ensembl_ids        external_id
#    ENSG00000160741    path:hsa04151
#    ENSG00000107175    path:hsa04151
#    ENSG00000198793    path:hsa04151
rule preprocess_cpdb:
    input: '{prefix}/raw/consensus_pathway_db/CPDB_pathways_genes.tab'
    output: '{prefix}/cleaned/consensus_pathway_db/CPDB_pathways_ensembl.tab'
    run:
        with open(output[0], 'w') as fout:
            for line in open(input[0]):
                toks = line.strip().split('\t')
                if len(toks) < 4:
                    continue
                for ens in toks[3].split(','):
                    fout.write('%s\t%s\n' % (ens, toks[1]))


# ----------------------------------------------------------------------------
# This rule takes the output from the RNA-seq zscores (genes x cellline,
# created in another snakefile) and applies the
# pipeline_helpers.pathway_scores_from_zscores function. See that function for
# details, but basically it assigns a "perturbation score" for each pathway.
# There are multiple types of scores calculated, and this is designated by
# a suffix at the end of each pathway ID.
#
# The result is a (pathway_score-method x cellline) table where each value is
# a "perturbation" score for that pathway in that cell line.
rule process_cpdb_zscores:
    input:
        zscores=config['features']['zscores']['output']['zscores'],
        cpdb_mapping=rules.preprocess_cpdb.output
    output: config['features']['cpdb']['output']['zscores']
    run:
        dfs = pipeline_helpers.pathway_scores_from_zscores(
            pd.read_table(str(input.zscores), index_col=0),
            pd.read_table(str(input.cpdb_mapping), index_col=0, names=['ENSEMBL', 'EXTERNAL_ID']),
            'EXTERNAL_ID'
        )
        dfs.to_csv(output[0], sep='\t', index_label='pathway_id')


# ----------------------------------------------------------------------------
# Like the above zscores rule, but uses a different function to do the score
# caclulation in a manner more appropriate for exome variants.
#
# Likewise, this generates a (pathway+suffix x cellline) table of perturbation
# scores.
rule process_cpdb_variants:
    input:
        variants=config['features']['exome_variants']['output']['by_gene'],
        cpdb_mapping=rules.preprocess_cpdb.output
    output: config['features']['cpdb']['output']['variants']
    run:
        dfs = pipeline_helpers.pathway_scores_from_variants(
            pd.read_table(str(input.variants), index_col=0),
            pd.read_table(str(input.cpdb_mapping), index_col=0, names=['ENSEMBL', 'EXTERNAL_ID']),
            'EXTERNAL_ID'
        )
        dfs.to_csv(output[0], sep='\t', index_label='pathway_id')

# vim: ft=python
