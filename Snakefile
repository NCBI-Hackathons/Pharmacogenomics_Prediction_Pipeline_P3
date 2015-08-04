# vim: ft=python

"""

"""

import os
from textwrap import dedent


targets = [

    'tools/data_qa.html',
    '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
    '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore_estimates.csv',
    '/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab',
    '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv',
    '/data/datasets/combined/gene_ontology/go_term_zscores.csv',
]


def compile_Rmd(fn):
    with open(os.path.basename(fn) + '.driver', 'w') as fout:
        fout.write(dedent(
            """
            library(knitr)
            library(rmarkdown)
            render("{0}", output_format="all", clean=TRUE)
            """.format(fn)))
    shell("/usr/bin/Rscript {0}".format(fout.name))
    shell("rm {0}".format(fout.name))


def run_R(fn, log=None):
    if log is not None:
        log = " > {0} 2> {0}".format(log)
    else:
        log = ""
    shell("/usr/bin/Rscript {fn} {log}")


rule all:
    input: targets


rule rmd:
    input: '{prefix}.Rmd'
    output: '{prefix}.html'
    run:
        compile_Rmd(input[0])


rule compute_zscores:
    input: "tools/rnaseq_data_zscore_calculation.R"
    output: 
        '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
        '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore_estimates.csv'
    run:
        run_R(input[0])


rule download_go:
    input: 'tools/generate_ensembl_go_mapping.R'
    output: '/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab'
    run:
        run_R(input[0])


rule rnaseq_data_prep:
    input:
        rscript='tools/rnaseq_data_preparation.R',
        infile='/data/datasets/raw/rnaseq_expression/HMCL_ensembl74_Counts.csv'
    output:
        '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv'
    run:
        run_R(input.rscript)


rule go_term_processing:
    input:
        rscript='tools/go_term_analysis.R',
        zscores='/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv',
        go_mapping='/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab',
    output: '/data/datasets/combined/gene_ontology/go_term_zscores.csv'
    log: 'tools/go_term_analysis.R.log'
    run:
        run_R(input.rscript, log)
