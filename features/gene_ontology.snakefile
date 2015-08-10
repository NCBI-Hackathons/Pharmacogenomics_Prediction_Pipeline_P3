# vim: ft=python

rule download_go:
    input: 'tools/generate_ensembl_go_mapping.R'
    output: '/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab'
    run:
        run_R(input[0])

rule go_term_processing:
    input:
        rscript='tools/go_term_analysis.R',
        zscores='/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
        go_mapping='/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab',
    output: config['features']['go']['output']
    log: 'tools/go_term_analysis.R.log'
    run:
        run_R(input.rscript, log)

