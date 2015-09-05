#!/bin/env Rscript
###############################################################################
#
# RNA-Seq data preparation
# Keith Hughitt
# 2015/08/04
#
# This script takes a raw count matrix with and performs some basic filtering
# and transformations on the data.
#
# The steps performed are:
#
# 1. Remove outlier samples
# 2. Low-count gene filtering
# 3. Counts-per-million (CPM)
# 4. Log2 transformation
# 5. Quantile normalization
#
###############################################################################
library('preprocessCore')

args = commandArgs(TRUE)

# Filepaths
infile  = args[1] #'/data/datasets/raw/rnaseq_expression/HMCL_ensembl74_Counts.csv'
outfile = args[2] #'/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv'

# Load raw count matrix
raw_counts = read.table(infile, row.names=1, sep='\t', header=TRUE)

# Sample IDs
sample_ids = colnames(raw_counts)

# Remove outlier samples
# JK6L_PLB appears as an outlier in the drug response profiles.
outliers = c('JK6L_PLB')
raw_counts = raw_counts[,!colnames(raw_counts) %in% outliers]

# Remove unexpressed genes
# threshold determines minimum number of reads a gene must have for a given
# sample, for at least 1 sample
threshold = 1

num_before = nrow(raw_counts)
keep = rowSums(raw_counts > threshold) >= 1
raw_counts = raw_counts[keep,]

print(sprintf("Removing %d low-count genes (%d remaining).",
    num_before - nrow(raw_counts), nrow(raw_counts)))

# Counts-per-million (CPM)
cpm = function (x) {
    sweep(x, 2, colSums(x), '/') * 1E6
}

# Log2-CPM
log2_cpm_counts = as.matrix(log2(cpm(raw_counts) + 0.5))

# Quantile normalized log2-CPM
log2_cpm_qnorm_counts = normalize.quantiles(log2_cpm_counts)

rownames(log2_cpm_qnorm_counts) = rownames(log2_cpm_counts)
colnames(log2_cpm_qnorm_counts) = colnames(log2_cpm_counts)

# Save output
if (!file.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)
}
write.csv(log2_cpm_qnorm_counts, file=outfile, quote=FALSE)

