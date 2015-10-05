rule compute_zscores:
    input: config['features']['normed_counts']['output']['normed_counts']
    output:
        zscores=config['features']['zscores']['output']['zscores'],
        estimates="{prefix}/cleaned/rnaseq_expression/zscore_estimates.csv"
    shell:
        """
        {Rscript} tools/rnaseq_data_zscore_calculation.R \
                {input} \
                {output.zscores} \
                {output.estimates}
        """

# vim: ft=python
