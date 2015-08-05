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
# 
# The steps performed are:
# 
# 1. calculate median and MAD by row (gene-wise)
# 2. calculate z-scores by row 
# 3. filter rows with NA or Inf values (Median == -1 | MAD == 0)
# 4. Save z-score and z-score estimates in separate files
# 5. Quantile normalization 
#
###############################################################################

fil = list.files('/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv')
dat = read.csv(fil, row=1)
med = apply(dat,1, median)
MAD = apply(dat,1, mad)
zdat = t(apply(dat, 1, function(x) (x-median(x))/mad(x)))
rem = apply(zdat, 1, function(x) any(is.na(x) | is.infinite(x)))
zout = zdat[!rem,]
MADout = MAD[!rem]
medout = med[!rem]
est = data.frame(Median=medout, MAD=MADout)
write.csv(zout, "HMCL_ensembl74_Counts_zscore.csv")
write.csv(est, "HMCL_ensembl74_Counts_zscore_estimates.csv")
