#!/bin/env Rscript
################################################################################
#
# Generate report visualizing features of SNP counts
# Author: Keith Hughitt <khughitt@umd.edu>
#
# Usage:
# ------
#
# ./visualize_exome_data.R INPUT.tsv OUTPUT.html <data_type> <data_level>
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
if (input_params$data_level == 'Cleaned') {
    template <- 'reports/templates/visualize_snps.Rmd'
}

# build report
render(template, output_file=outfile, params=input_params)
