# vim: ft=python

rule rnaseq_data_prep:
    input:
        "{prefix}/raw/rnaseq_expression/HMCL_ensembl74_Counts.csv"
    output:
        config['features']['normed_counts']['output']
    shell:
        """
        {Rscript} tools/rnaseq_data_preparation.R {input} {output}
        """

