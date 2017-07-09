#!/bin/env Rscript
###############################################################################
#
# post_processing.R
#
# Keith Hughitt <khughitt@umd.edu>
# 2016/07/11
#
# Processes SuperLearner results from P3 and generates smaller summary
# statistic data.frames
#
# Usage Example:
#
# ./post_processing.R \
#      /path/to/runs/run-x/output/NCGC00262604-01.RData \
#      /path/to/runs/run-x/post-processed/NCGC00262604-01.RData
#
###############################################################################

# parse command-line arguments
args <- commandArgs(trailing=TRUE)

infile  <- args[1]
outfile <- args[2]

# Check to make sure output directory exists, and if not, create it
if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)
}

# load P3 SuperLearner results
load(infile)

# generate summary list
p3_result <- list(
    drug_name           = sub('.RData', '', basename(infile)),
    prediction_variance = var(out.SL$SL.predict[,1]),
    feature_importance  = out.SL$fitLibrary$SL.randomForest_All$object$importance,
    superlearner_coefs  = out.SL$coef,
    superlearner_risks  = out.SL$cvRisk
)

# save result
save(p3_result, file=outfile)
