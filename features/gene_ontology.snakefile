# vim: ft=python
import pandas as pd

rule download_go:
    output: '{prefix}/raw/gene_ontology/ensembl_go_mapping.tab'
    shell:
        """
        {Rscript} tools/generate_ensembl_go_mapping.R {output}
        """

rule go_term_processing:
    input:
        zscores='{prefix}/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
        go_mapping='{prefix}/raw/gene_ontology/ensembl_go_mapping.tab',
    output: config['features']['go']['output']
    run:
        dfs = pipeline_helpers.pathway_scores_from_zscores(
            pd.read_csv(str(input.zscores), index_col=0),
            pd.read_table(str(input.go_mapping), index_col=0),
            'GO'
        )

        dfs.T.to_csv(output[0])
