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
    '/data/datasets/raw/msig_db/c2.cp.v5.0.ensembl.tab',
    '/data/datasets/combined/msig_db/msig_db_zscores.csv',
]

# The main targets are the regression outputs.
DRUG_RESPONSES = "/data/datasets/filtered/drug_response/iLAC50_filtered.csv"
import pandas
i = 0
for drug_id in pandas.read_table(DRUG_RESPONSES, sep=',', index_col=0).index:
    i += 1
    if i == 11:
        break
    targets.append(
        '/data/datasets/final/regression/SuperLearner/outSL_{0}.RData'.format(drug_id)
    )

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

rule msigdb_preprocessing:
    input:
        pyscript='tools/process_msigdb.py',
        msigdb='/data/datasets/raw/msig_db/c2.cp.v5.0.entrez.gmt'
    output: '/data/datasets/raw/msig_db/c2.cp.v5.0.ensembl.tab'
    run:
        shell('python {input.pyscript}')

rule msigdb_processing:
    input:
        rscript='tools/msigdb_analysis.R',
        ensembl_msigdb='/data/datasets/raw/msig_db/c2.cp.v5.0.ensembl.tab'
    output: '/data/datasets/combined/msig_db/msig_db_zscores.csv'
    log: 'tools/msigdb_analysis.R.log'
    run:
        run_R(input.rscript, log)


rule superlearner:
    input:
        rnaseq="/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv",
        drug_response_input="/data/datasets/filtered/drug_response/iLAC50_filtered.csv"
    output: "/data/datasets/final/regression/SuperLearner/outSL_{drug_id}.RData"
    params: rscript='tools/prediction_algorithm_analysis.R'
    log: "/data/datasets/final/regression/SuperLearner/outSL_{drug_id}.log"
    shell:
        '''
        /usr/bin/Rscript {params.rscript} {wildcards.drug_id}
        '''
