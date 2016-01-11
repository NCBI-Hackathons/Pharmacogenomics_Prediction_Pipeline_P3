#!/bin/env Rscript
################################################################################
#
# Generate report visualizing features of RNA-Seq counts
# Author: Keith Hughitt <khughitt@umd.edu>
#
# Usage:
# ------
#
# ./visualize_rnaseq INPUT.tsv <title>
# 
################################################################################
library(rmarkdown)

# parse command-line arguments
args <- commandArgs(trailing=TRUE)

infile         <- args[1]
outfile        <- args[2]
analysis_title <- args[3]

# create output directory if it doesn't already exist
if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile, recursive=TRUE))
}

# render knitr report
render('reports/templates/visualize_rnaseq.Rmd', output_file=outfile)
