#!/bin/env Rscript
#####################################################################
#
#    RUN ONE TIME to write out metadata file for exome variants
#    "raw/sample_ids_exome variants.csv" 
#
#   ammhub
#   2015/08/14
#
#####################################################################

# input 
dir_in <- 'data/datasets/raw/exome_variants'
    
# output
dir_meta_out <- 'data/datasets/raw/metadata'
if (!dir.exists(dir_meta_out))  dir.create(dir_meta_out, recursive = T)

file_out_sample_ids <- file.path(dir_meta_out, 'sample_ids_exome_variants.csv')

# generate metadata file with sample ids/names/file names
sampleFile <- list.files(dir_in)
sampleId <- sapply(strsplit(sampleFile, '_'), function(x) paste(x[1:2], collapse='_'))
sampleName <- sapply(strsplit(sampleId, '_'), function(x) return(x[1]))
sampleName[grep("KMS11", sampleName)] <- c("KMS11JCRB", "KMS11JCRB", "KMS11JPN")
temp = data.frame(SAMPLE_ID = sampleId, SAMPLE_NAME = sampleName, SAMPLE_FILE = sampleFile)
write.csv(temp, file_out_sample_ids, row.names = FALSE, quote = FALSE)
