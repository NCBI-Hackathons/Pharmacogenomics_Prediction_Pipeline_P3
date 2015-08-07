# vim ft=python
rule rnaseq_data_prep:
    input:
        rscript='tools/rnaseq_data_preparation.R',
        infile='/data/datasets/raw/rnaseq_expression/HMCL_ensembl74_Counts.csv'
    output:
        config['features']['normed_counts']['output']
    run:
        run_R(input.rscript)

