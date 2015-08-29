#!/bin/env Rscript
#########################################################################################
#
# RNA-Seq data preparation
# Keith Hughitt
# 2015/08/04
#
# - modified rnaseq_data_preparation.R to add step for reading separate files per sample
#   ammhub
#   2015/08/13
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
########################################################################################
library('preprocessCore')

# Filepaths

#infile  = '/data/datasets/raw/rnaseq_expression/HMCL_ensembl74_Counts.csv'
dir_in <- 'data/datasets/raw/rnaseq_expression'
dir_meta_in <- 'data/datasets/raw/metadata'
file_in_sample_ids <- file.path(dir_meta_in, 'sample_ids_rnaseq_expression.csv')

outfile = 'data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv'

#. read sample ids and files
sampleIds <- read.csv(file_in_sample_ids)
sampleFiles <- sampleIds$SAMPLE_FILE
varExpr <- 'counts'
rowUID <- 'GENE_ID'

datList <- list()
for (i in 1:length(sampleFiles)){
  datList[[i]] <- read.csv(file.path(dir_in, sampleFiles[i]))
}

#. check row UID across samples
x <- sapply(datList, function(x) return(x[,rowUID]))
yes <- apply(x, 1, function(x) all(x == x[1]))
if (any(!yes)) stop("compound ids ('GENE_ID') do not match across samples")

#. cbind into matrix
rowNames <- datList[[1]][,rowUID]
colNames <- sampleIds$SAMPLE_ID
raw_counts <- sapply(datList, function(x) return(x[,varExpr]))
dimnames(raw_counts) = list(rowNames, colNames)
 
 
# Load raw count matrix
#raw_counts = read.csv(infile, row.names=1)

# Sample IDs
#sample_ids = colnames(raw_counts)

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
write.csv(log2_cpm_qnorm_counts, file=outfile, quote=FALSE)
