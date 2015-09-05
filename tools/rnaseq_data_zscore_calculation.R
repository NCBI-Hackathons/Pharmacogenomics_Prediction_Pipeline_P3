#!/bin/env Rscript
###############################################################################
#
# RNA-Seq data preparation
# Aleksandra Michalowski
# 2015/08/04
#
# This script takes normalized and filtered counts matrix
# and calculates median based z-score data
#
# Usage:
#
#   Rscript rnaseq_data_zscore_calculation.R \
#       {normalized counts file} \
#       {zscores output file} \
#       {MAD output file}
#
#
#
# The steps performed are:
#
# 1. calculate median and MAD by row (gene-wise)
# 2. calculate z-scores by row
# 3. filter rows with NA or Inf values (Median == -1 | MAD == 0)
# 4. Save z-score and z-score estimates in separate files (specified as last 2 arguments)
# 5. Quantile normalization
#
###############################################################################
args = commandArgs(TRUE)
infile = args[1]
out1 = args[2]
out2 = args[3]
dat = read.table(infile, row=1, header=TRUE)
med = apply(dat,1, median)
MAD = apply(dat,1, mad)
zdat = t(apply(dat, 1, function(x) (x-median(x))/mad(x)))
rem = apply(zdat, 1, function(x) any(is.na(x) | is.infinite(x)))
zout = zdat[!rem,]
MADout = MAD[!rem]
medout = med[!rem]
est = data.frame(Median=medout, MAD=MADout)
write.csv(zout, out1)
write.csv(est, out2)
