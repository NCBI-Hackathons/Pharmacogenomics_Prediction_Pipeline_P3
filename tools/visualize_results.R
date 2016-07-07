#!/bin/env Rscript
################################################################################
#
# Generate report visualizing P3 results
# Author: Keith Hughitt <khughitt@umd.edu>
#
# Usage:
# ------
#
# ./visualize_results.R path/to/results/*.RData path/to/outdir
# 
################################################################################
library(rmarkdown)

# parse command-line arguments
args <- commandArgs(trailing=TRUE)

output_dir <- args[2]

input_params <- list(
    results_glob_str = args[1],
    output_dir       = output_dir
)

# Output filepath
outfile <- file.path(output_dir, 'results.html')

# render knitr report
template <- 'reports/templates/visualize_results.Rmd'

# build report
render(template, output_file=outfile, params=input_params)
