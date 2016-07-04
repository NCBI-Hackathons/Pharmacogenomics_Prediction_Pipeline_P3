#!/bin/env Rscript
################################################################################
#
# Generate report visualizing P3 results
# Author: Keith Hughitt <khughitt@umd.edu>
#
# Usage:
# ------
#
# ./visualize_results.R path/to/results/*.RData OUTPUT.html
# 
################################################################################
library(rmarkdown)

# parse command-line arguments
args <- commandArgs(trailing=TRUE)

input_params <- list(
    results_glob_str = args[1]
)

# Output filepath
outfile <- args[2]

# create output directory if it doesn't already exist
if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile, recursive=TRUE))
}

# render knitr report
template <- 'reports/templates/visualize_results.Rmd'

# build report
render(template, output_file=outfile, params=input_params)
