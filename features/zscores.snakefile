rule compute_zscores:
    input: config['features']['normed_counts']['output']
    output:
        zscores=config['features']['zscores']['output'][0],
        estimates=config['features']['zscores']['output'][1]
    shell:
        """
        {Rscript} tools/rnaseq_data_zscore_calculation.R \
                {input} \
                {output.zscores} \
                {output.estimates}
        """

# vim: ft=python
