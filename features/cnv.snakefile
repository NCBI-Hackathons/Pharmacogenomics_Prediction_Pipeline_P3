import os
import numpy as np
import pandas as pd

# ----------------------------------------------------------------------------
# Convert SEG-format files to sorted BED format
rule seg_to_bed:
    input: '{prefix}/raw/cnv/{sample}_cnv.seg'
    output: '{prefix}/cleaned/cnv/{sample}_cnv.bed'
    shell:
        """
        {programs.bedtools.prelude}
        tail -n +2 {input} | awk -F "\\t" '{{OFS="\\t"; print $2,$3,$4,$6}}' \\
            | {programs.bedtools.path} sort -i stdin > {output}
        """

# ----------------------------------------------------------------------------
# Use the bedtools multiinter algorithm to cluster into segments of unique
# blocks. Here is the result of running `bedtools multiinter -examples` to show
# what it's doing:
#
# == Input files: ==
#
#  $ cat a.bed
#  chr1  6   12
#  chr1  10  20
#  chr1  22  27
#  chr1  24  30
#
#  $ cat b.bed
#  chr1  12  32
#  chr1  14  30
#
#  $ cat c.bed
#  chr1  8   15
#  chr1  10  14
#  chr1  32  34
#
#  $ cat sizes.txt
#  chr1  5000
#
# == Multi-intersect the files: ==
#
#  $ multiIntersectBed -i a.bed b.bed c.bed
# chr1    6    8    1   1      1    0    0
# chr1    8    12   2   1,3    1    0    1
# chr1    12   15   3   1,2,3  1    1    1
# chr1    15   20   2   1,2    1    1    0
# chr1    20   22   1   2      0    1    0
# chr1    22   30   2   1,2    1    1    0
# chr1    30   32   1   2      0    1    0
# chr1    32   34   1   3      0    0    1
#
#
# Note that this rule runs once, using all BED files created above. Also we
# only grab the first 3 fields of the output to use later.
rule multi_intersect:
    input: expand('{{prefix}}/cleaned/cnv/{sample}_cnv.bed', sample=samples)
    output: '{prefix}/cleaned/cnv/clustered.bed'
    shell:
        """
        {programs.bedtools.prelude}
        {programs.bedtools.path} multiinter -i {input} | awk -F "\\t" '{{OFS="\\t"; print $1,$2,$3}}' \\
            | {programs.bedtools.path} sort -i stdin > {output}
        """

# ----------------------------------------------------------------------------
# Intersect the clustered output with the CNV data in BED format.
#
# Runs once for each sample.
#
# The output has some double tab characters that need to be removed.
#
# The output is a 2-column, tab-delimited file where the first column is
# a constructed identifier of the cluster (of the form "chrom_start_stop")
# followed by the score for that sample within that cluster.
rule create_cluster_scores:
    input:
        clusters=rules.multi_intersect.output[0],
        cnv_bed=rules.seg_to_bed.output
    output: '{prefix}/cleaned/cnv/{sample}_cnv_cluster_overlaps.tab'
    shell:
        """
        {programs.bedtools.prelude}
        {programs.bedtools.path} intersect -a {input.clusters} -b {input.cnv_bed} -sorted -wao  \\
            | sed "s/\\t\\t/\\t/g" \\
            | awk -F "\\t" '{{OFS="\\t"; print $1"_"$2"_"$3, $7}}' > {output}
        """


# ----------------------------------------------------------------------------
# Stitch together all of the cluster scores based on the constructed identifier
# for each cluster.
#
rule cluster_matrix:
    input: expand("{{prefix}}/cleaned/cnv/{sample}_cnv_cluster_overlaps.tab", sample=samples)
    output: '{prefix}/cleaned/cnv/cluster_scores.tab'
    run:
        df = pipeline_helpers.stitch(
            input,
            lambda x: os.path.basename(x).replace('_cnv_cluster_overlaps.tab', ''),
            na_values=['.', '-1'],
        )
        df = df.fillna(0)
        df.to_csv(str(output[0]), sep='\t', index_label='cluster_id')

# ----------------------------------------------------------------------------
# Compute a CNV score for each gene.
#
# This runs once for each sample.
#
# Two ways of computing scores are shown here: "max" and "longest". See the
# docs for more info.
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
