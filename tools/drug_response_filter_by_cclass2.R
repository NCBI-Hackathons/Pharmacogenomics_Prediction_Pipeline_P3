#!/bin/env Rscript
###############################################################################################
#
#  drug response data filtering
# 
#  ammhub
#  2015/08/11
#
#  This script reads processed files per sample from processed/drug_response/drc/<SAMPLE_ID>_drc.csv
# 
#  The steps performed are:
#    1. choose which drug sensitivity estimates to ouput (here: iLAC50 and CCLASS2)
#    2. select subset of drugs where at least some samples responded well:
#      here: CCLASS2 == -1.1 in at least 5 samples
#    3. write out separate files for each chosen sensitivity estimate:
#      [compounds, samples] matrix in filtered/drug_response/<estimate>_filtered.csv
#
#################################################################################################


#--> HARD CODED: paths

#. input 
dir_in <- 'datasets/processed/drug_response/drc'
dir_meta_in <- 'datasets/processed/metadata/'

#. output
dir_out <- 'datasets/filtered/drug_response'
if (!dir.exists(dir_out))  dir.create(dir_out, recursive = T)
dir_meta_out <- 'datasets/filtered/metadata'
if (!dir.exists(dir_meta_out))  dir.create(dir_meta_out, recursive = T)
    
#--> HARD CODED: variable names and options
kSamples <- 5
kClass2 <- -1.1
curveClass2 <- 'CCLASS2'
estimates <- c('iLAC50','CCLASS2')
rowUID <- 'SID'


#--> FUNCTIONS
SingleMatrix <- function(x.list, variable, row.ids, col.ids){
  out <- sapply(x.list, function(x) return(x[,variable]))
  dimnames(out) = list(row.ids, col.ids)
  return(out)
}
GetSampleNames <- function(x.names, break.by = '_', k = 2)
  sapply(strsplit(x.names, break.by), function(x) return(paste(x[1:k], collapse = break.by)))


#--> RUN

#. read in data
sampleFiles <- list.files(dir_in)
datList <- list()
for (i in 1:length(sampleFiles)){
  datList[[i]] <- read.csv(file.path(dir_in, sampleFiles[i]))
}
#. check row UID across samples
x <- sapply(datList, function(x) return(x[,rowUID]))
yes <- apply(x, 1, function(x) all(x == x[1]))
if (any(!yes)) stop("compound ids ('SID') do not match across samples")

#. set compounds and sample names
rowNames <- datList[[1]][,rowUID]
colNames <- GetSampleNames(sampleFiles)

#. get CCLASS2 matrix and select drugs
matClass2 <- SingleMatrix(datList, variable = curveClass2, row.ids = rowNames, col.ids = colNames)
nSamples <- apply(matClass2, 1, function(x) return(sum(x == kClass2)))
selDrugs <- nSamples >= kSamples
 
#.   write out drug sensitivity matrices
for (i in 1:length(estimates)){
  temp <- SingleMatrix(datList, variable = estimates[i], row.ids = rowNames, col.ids = colNames)
  temp <- temp[selDrugs,]
  temp <- data.frame(rownames(temp), temp)
  names(temp)[1] = rowUID
  write.csv(temp, file.path(dir_out, paste(estimates[i], 'filtered.csv', sep='_')),
    row.names = FALSE, quote=TRUE)
}
