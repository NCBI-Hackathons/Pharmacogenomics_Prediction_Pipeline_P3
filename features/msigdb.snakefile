import pandas as pd

rule msigdb_preprocessing:
    input:
        msigdb_downloaded_file='{prefix}/raw/msig_db/c2.cp.v5.0.entrez.gmt',
        lookup='{prefix}/metadata/ENSG2ENTREZID.tab'
    output: '{prefix}/cleaned/msig_db/c2.cp.v5.0.ensembl.tab'
    run:
        """
        Convert msigdb Entrez accessions to Ensembl. Since there are some one-to-many
        mappings of entrez to ensembl, we repeat those rows so one row corresponds to
        one Ensembl ID.

        MSIG requires a confirmation page, so its download cannot be well automated. So
        here we expect the presence of the already-downloaded file.

        This downloaded file has an awkward format: pathway name, url, followed by an
        arbitrary number of Entrez IDs annotated for that pathway. This script uses the
        MyGene.info service to lookup entrez to ensemble IDs, and then creates an
        output file mapping Ensembl accession to pathway.
        """
        gene_to_pathway = []
        fn = str(input.msigdb_downloaded_file)
        for line in open(fn):
            line = line.strip().split('\t')
            pathway = line[0]
            for entrez in line[2:]:
                gene_to_pathway.append((entrez, pathway))

        df = pd.DataFrame(gene_to_pathway, columns=['entrez_id', 'pathway'])
        df.index = df['entrez_id'].astype(int)
        del df['entrez_id']

        lookup = pd.read_table(str(input.lookup), index_col='ENTREZID')
        df = df.join(lookup).dropna(subset=['ENSEMBL'])
        df.index = df['ENSEMBL']
        del df['ENSEMBL']
        df.to_csv(str(output[0]), sep='\t', index_label='pathway id')


rule msigdb_zscores:
    input:
        zscores=config['features']['zscores']['output']['zscores'],
        msig_mapping=rules.msigdb_preprocessing.output
    output: config['features']['msigdb']['output']['zscores']
    run:
        dfs = pipeline_helpers.pathway_scores_from_zscores(
            pd.read_table(str(input.zscores), index_col=0),
            pd.read_table(str(input.msig_mapping), names=['ENSEMBL', 'PATHWAY'], index_col=0),
            'PATHWAY'
        )

        dfs.to_csv(output[0], sep='\t', index_label='pathway_id')


rule msigdb_variants:
    input:
        variants=config['features']['exome_variants']['output'],
        msig_mapping=rules.msigdb_preprocessing.output
    output: config['features']['msigdb']['output']['variants']
    run:
        dfs = pipeline_helpers.pathway_scores_from_variants(
            pd.read_table(str(input.variants), index_col=0),
            pd.read_table(str(input.msig_mapping), names=['ENSEMBL', 'PATHWAY'], index_col=0),
            'PATHWAY'
        )
        dfs.to_csv(output[0], sep='\t', index_label='pathway_id')



# vim: ft=python

