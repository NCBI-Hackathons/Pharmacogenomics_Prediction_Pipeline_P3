import os
import numpy as np
import pandas as pd

rule seg_to_bed:
    input: '{prefix}/raw/cnv/{sample}_cnv.seg'
    output: '{prefix}/cleaned/cnv/{sample}_cnv.bed'
    shell:
        """
        {programs.bedtools.prelude}
        tail -n +2 {input} | awk -F "\\t" '{{OFS="\\t"; print $2,$3,$4,$6}}' \\
            | {programs.bedtools.path} sort -i stdin > {output}
        """

rule multi_intersect:
    input: expand('{{prefix}}/cleaned/cnv/{sample}_cnv.bed', sample=samples)
    output: '{prefix}/cleaned/cnv/clustered.bed'
    shell:
        """
        {programs.bedtools.prelude}
        {programs.bedtools.path} multiinter -i {input} | awk -F "\\t" '{{OFS="\\t"; print $1,$2,$3}}' \\
            | {programs.bedtools.path} sort -i stdin > {output}
        """

rule create_cluster_scores:
    input:
        clusters=rules.multi_intersect.output[0],
        cnv_bed=rules.seg_to_bed.output
    output: '{prefix}/cleaned/cnv/{sample}_cnv_cluster_overlaps.bed'
    shell:
        """
        {programs.bedtools.prelude}
        {programs.bedtools.path} intersect -a {input.clusters} -b {input.cnv_bed} -sorted -wao  \\
            | sed "s/\\t\\t/\\t/g" \\
            | awk -F "\\t" '{{OFS="\\t"; print $1"_"$2"_"$3, $7}}' > {output}
        """


rule cluster_matrix:
    input: expand("{{prefix}}/cleaned/cnv/{sample}_cnv_cluster_overlaps.bed", sample=samples)
    output: '{prefix}/cleaned/cnv/cluster_scores.tab'
    run:
        df = pipeline_helpers.stitch(
            input,
            lambda x: os.path.basename(x).replace('_cnv_cluster_overlaps.bed', ''),
            na_values=['.', '-1'],
        )
        df = df.fillna(0)
        df.to_csv(str(output[0]), sep='\t', index_label='cluster_id')

rule create_gene_scores:
    input:
        genes="example_data/metadata/genes.bed",
        cnv_bed=rules.seg_to_bed.output
    output:
        intersected='{prefix}/cleaned/cnv/{sample}_cnv_gene.bed',
        gene_max='{prefix}/cleaned/cnv/{sample}_cnv_gene_max_scores.bed',
        gene_longest='{prefix}/cleaned/cnv/{sample}_cnv_gene_longest_overlap_scores.bed'
    run:
        # Intersect the BED file of this cel
        shell("""
              {programs.bedtools.prelude}
              {programs.bedtools.path} intersect -a {input.cnv_bed} -b {input.genes} -wao \\
              | sed "s/\\t\\t/\\t/g" > {output.intersected}
        """)
        df = pd.read_table(
            str(output.intersected),
            names=['smp_chrom', 'smp_start', 'smp_end', 'smp_score', 'g_chrom',
                   'g_start', 'g_end', 'g_name', 'g_smp_overlap'],
            na_values=['.', '-1']
        )
        df[['g_name', 'smp_score']].groupby('g_name').agg(np.max).to_csv(str(output.gene_max), sep='\t')
        df[['g_name', 'smp_score', 'g_smp_overlap']].groupby('g_name').agg(
            lambda x: x['smp_score'][x['g_smp_overlap'].argmax()])[['smp_score']].to_csv(str(output.gene_longest), sep='\t')


rule gene_longest_overlap_scores_matrix:
    input: expand('{{prefix}}/cleaned/cnv/{sample}_cnv_gene_longest_overlap_scores.bed', sample=samples)
    output: '{prefix}/cleaned/cnv/cnv_gene_longest_overlap_scores.tab'
    run:
        df = pipeline_helpers.stitch(
            input,
            lambda x: os.path.basename(x).split('_cnv_gene')[0],
        )
        df.to_csv(str(output), sep='\t', index_label='gene_id')


rule gene_max_scores_matrix:
    input: expand('{{prefix}}/cleaned/cnv/{sample}_cnv_gene_max_scores.bed', sample=samples)
    output: '{prefix}/cleaned/cnv/cnv_gene_max_scores.tab'
    run:
        df = pipeline_helpers.stitch(
            input,
            lambda x: os.path.basename(x).split('_cnv_gene')[0],
        )
        df.to_csv(str(output), sep='\t', index_label='gene_id')



# vim: ft=python
