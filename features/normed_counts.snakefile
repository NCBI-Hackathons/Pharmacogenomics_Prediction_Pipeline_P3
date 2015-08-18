# vim: ft=python
import pandas
import os
samples = [i.strip() for i in open(config['samples'])]



rule rnaseq_counts_matrix:
    input: expand('{{prefix}}/raw/rnaseq_expression/{sample}_counts.csv', sample=samples)
    output: '{prefix}/raw/rnaseq_expression/counts_matrix.csv'
    run:
        df = pipeline_helpers.stitch(
            input,
            lambda x: os.path.basename(fn).replace('_counts.csv', ''),
            index_col=0,
            sep=','
        )
        df.to_csv(output[0])


rule rnaseq_data_prep:
    input:
        "{prefix}/raw/rnaseq_expression/counts_matrix.csv"
    output:
        config['features']['normed_counts']['output']
    shell:
        """
        {Rscript} tools/rnaseq_data_preparation.R {input} {output}
        """

