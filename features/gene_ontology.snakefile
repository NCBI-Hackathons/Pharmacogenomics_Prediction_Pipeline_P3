# vim: ft=python

rule download_go:
    output: '{prefix}/raw/gene_ontology/ensembl_go_mapping.tab'
    shell:
        """
        {Rscript} tools/generate_ensembl_go_mapping.R {output}
        """

rule go_term_processing:
    input:
        rscript='tools/go_term_analysis.R',
        zscores='/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
        go_mapping='/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab',
    output: config['features']['go']['output']
    log: 'tools/go_term_analysis.R.log'
    run:
        run_R(input.rscript, log)

