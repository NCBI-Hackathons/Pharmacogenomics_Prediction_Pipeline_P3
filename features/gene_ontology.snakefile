# vim: ft=python
import pandas as pd

rule download_go:
    output: '{prefix}/raw/gene_ontology/ensembl_go_mapping.tab'
    shell:
        """
        {Rscript} tools/generate_ensembl_go_mapping.R {output}
        """

rule go_term_zscores:
    input:
        zscores=config['features']['zscores']['output']['zscores'],
        go_mapping=rules.download_go.output
    output: config['features']['go']['output']['zscores']
    run:
        dfs = pipeline_helpers.pathway_scores_from_zscores(
            pd.read_csv(str(input.zscores), index_col=0),
            pd.read_table(str(input.go_mapping), index_col=0),
            'GO'
        )

        dfs.T.to_csv(output[0])
