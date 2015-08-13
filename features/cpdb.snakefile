rule preprocess_cpdb:
    input: '{prefix}/raw/consensus_pathway_db/CPDB_pathways_genes.tab'
    output: '{prefix}/raw/consensus_pathway_db/CPDB_pathways_ensembl.tab'
    run:
        with open(output[0], 'w') as fout:
            for line in open(input[0]):
                toks = line.strip().split('\t')
                if len(toks) < 4:
                    continue
                for ens in toks[3].split(','):
                    fout.write('%s\t%s\n' % (ens, toks[1]))


rule process_cpdb_zscores:
    input:
        zscores=config['features']['zscores']['output']['zscores'],
        cpdb_mapping=rules.preprocess_cpdb.output
    output: config['features']['cpdb']['output']['zscores']
    run:
        dfs = pipeline_helpers.pathway_scores_from_zscores(
            pd.read_csv(str(input.zscores), index_col=0),
            pd.read_table(str(input.cpdb_mapping), index_col=0, names=['ENSEMBL', 'EXTERNAL_ID']),
            'EXTERNAL_ID'
        )
        dfs.T.to_csv(output[0])

        dfs.T.to_csv(output[0])

# vim: ft=python
