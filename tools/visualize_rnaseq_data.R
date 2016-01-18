#!/bin/env Rscript
################################################################################
#
# Generate report visualizing features of RNA-Seq counts
# Author: Keith Hughitt <khughitt@umd.edu>
#
# Usage:
# ------
#
# ./visualize_rnaseq_data.R INPUT.tsv OUTPUT.html <data_type> <data_level>
# 
################################################################################
library(rmarkdown)

# parse command-line arguments
args <- commandArgs(trailing=TRUE)

input_params <- list(
    infile     = args[1],
    data_type  = args[3],
    data_level = args[4]
)

outfile <- args[2]

# create output directory if it doesn't already exist
if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile, recursive=TRUE))
}

# render knitr report
if (input_params$data_level == 'Raw') {
    template <- 'reports/templates/visualize_rnaseq_raw.Rmd'
} else {
    template <- 'reports/templates/visualize_rnaseq_normed.Rmd'
}

# build report
render(template, output_file=outfile, params=input_params)
