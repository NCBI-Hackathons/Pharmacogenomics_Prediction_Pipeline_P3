# vim: ft=python
import pandas
import os
samples = [i.strip() for i in open(config['samples'])]



rule rnaseq_counts_matrix:
    input: expand('{{prefix}}/raw/rnaseq_expression/{sample}_counts.csv', sample=samples)
    output: '{prefix}/raw/rnaseq_expression/counts_matrix.csv'
    run:
        def sample_from_filename(fn):
            return os.path.basename(fn).replace('_counts.csv', '')

        dfs = []
        names = []
        for fn in input:
            dfs.append(pandas.read_csv(fn, index_col=0))
            names.append(sample_from_filename(fn))
        df = pandas.concat(dfs, axis=1)
        df.columns = names
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

