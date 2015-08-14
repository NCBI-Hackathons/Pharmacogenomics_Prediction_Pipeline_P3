#!/bin/env Rscript
####################################################################
#
#    RUN ONE TIME to write out separate files per sample (raw) from
#    "HMCL_ensembl74_Counts.csv" file and metadata 
#    sample_ids_rnaseq_expression.csv
#
#   ammhub
#   2015/08/13
#
####################################################################

# input 
file_in <- 'data/datasets/raw/rnaseq_expression/HMCL_ensembl74_Counts.csv'
    
# output
dir_out <- 'data/datasets/raw/rnaseq_expression'
if (!dir.exists(dir_out))  dir.create(dir_out, recursive = T)
dir_meta_out <- 'data/datasets/raw/metadata'
if (!dir.exists(dir_meta_out))  dir.create(dir_meta_out, recursive = T)

file_out_sample_ids <- file.path(dir_meta_out, 'sample_ids_rnaseq_expression.csv')
file_out_skip <- "HMCL_ensembl74_Counts.csv"
  
# RUN

#. write out columns + gene ids to separate files
datMat <- read.csv(file_in, row=1)
for (i in 1:ncol(datMat)){
  temp <- data.frame(GENE_ID = rownames(datMat), counts = datMat[,i])
  write.csv(temp, file = file.path(dir_out, paste(colnames(datMat)[i], '_counts.csv', sep = '')),
    row.names = FALSE, quote = FALSE)
}

#. generate metadata file with sample ids/names/file names
sampleId <- colnames(datMat)
sampleName <- sapply(strsplit(sampleId, '_'), function(x) return(x[1]))
sampleName[grep("KMS11", sampleName)] <- c("KMS11JCRB", "KMS11JCRB", "KMS11JPN")
sampleFile <- paste(sampleId, '_counts.csv', sep='')
temp = data.frame(SAMPLE_ID = sampleId, SAMPLE_NAME = sampleName, SAMPLE_FILE = sampleFile)
write.csv(temp, file_out_sample_ids, row.names = FALSE, quote = FALSE)
