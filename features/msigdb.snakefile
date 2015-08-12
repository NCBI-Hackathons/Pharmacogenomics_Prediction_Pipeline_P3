rule msigdb_preprocessing:
    input: '{prefix}/raw/msig_db/c2.cp.v5.0.entrez.gmt'
    output: '{prefix}/raw/msig_db/c2.cp.v5.0.ensembl.tab'
    shell:
        "python tools/process_msigdb.py {input} {output}"

rule msigdb_processing:
    input:
        zscores='{prefix}/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
        msig_mapping='{prefix}/raw/msig_db/c2.cp.v5.0.ensembl.tab'
    output: config['features']['msigdb']['output']
    run:
        dfs = pipeline_helpers.pathway_scores_from_zscores(
            pd.read_csv(str(input.zscores), index_col=0),
            pd.read_table(str(input.msig_mapping), names=['ENSMEBL', 'PATHWAY'], index_col=0),
            'PATHWAY'
        )

        dfs.T.to_csv(output[0])

# vim: ft=python

