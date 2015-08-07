# vim: ft=python
rule compute_zscores:
    input: '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv'
    output: 
        '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
        '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore_estimates.csv'
    shell:
        """
        Rscript tools/rnaseq_data_zscore_calculation.R \
                {input} \
                {output[0]} \
                {output[1]}
        """

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

