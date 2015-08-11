#!/bin/env Rscript
###############################################################################################
#
#  drug response data preparation
# 
#  ammhub
#  2015/08/11
#
# This script reads NCATS default output files (single file per sample)
# 
# The steps performed are:
#   1. retains compounds tested across all samples
#   2. calculates AC50 (back from log AC50); adds variable named AC50
#   3. assigns highest dose to missing AC50 if class curve2 equals 4; adds variable named iAC50
#   4. calculates negative log with iAC50: adds variable named iLAC50
#   5. splits data and writes out files with different type of data:
#      - compound ids/names to one file (metadata)
#      - compound doses to one file (metadata); assumes the same doses for a particular drug
#      - response data (normalized percentage of viable cells) to a single file per sample
#      - drc (dose response curve fit and sensitivity estimates) to a single file per sample
#   5a. NCATS file names in the written out single files per sample are replaced
#        and include unique SAMPLE_ID from the raw/metadata/samples_ids_drug_response.csv file
# 
#################################################################################################


#--> HARD CODED: paths

#. input 
dir_in <- 'datasets/raw/drug_response'
dir_meta_in <- 'datasets/raw/metadata/'
    
file_in_samples_ids <- file.path(dir_meta_in, 'samples_ids_drug_response.csv')

#. output
dir_out <- 'datasets/processed/drug_response'
if (!dir.exists(dir_out))  dir.create(dir_out, recursive = T)
    
dir_out_drc <- 'datasets/processed/drug_response/drc'
if (!dir.exists(dir_out_drc))  dir.create(dir_out_drc, recursive = T)
    
dir_out_response <- 'datasets/processed/drug_response/response'
if (!dir.exists(dir_out_response))  dir.create(dir_out_response, recursive = T)
    
dir_meta_out <- 'datasets/processed/metadata'
if (!dir.exists(dir_meta_out))  dir.create(dir_meta_out, recursive = T)
    
file_out_compounds_ids <- file.path(dir_meta_out, 'compounds_ids_drug_response.csv')
file_out_doses <- file.path(dir_meta_out, 'doses_drug_response.csv')



#--> HARD CODED: options/parameters

#. variable name for unique drug id
rowUID <- 'SID'

#. variable names for splitting data by content
varCompound <- c('SID', 'readout', 'name', 'target', 'smi')
varDRC <- c('NPT', 'CCLASS', 'CCLASS2', 'HILL', 'INF', 'ZERO', 'MAXR', 'TAUC', 'FAUC', 'LAC50')
varDose <- paste('C', 0:10, sep='')
varResponse <- paste('DATA', 0:10, sep='')

#. settings for assigning AC50 if missing
kBadCurve <- 4
curveClass2 <- 'CCLASS2'
subDose <- 'C10'
logAC50 <- 'LAC50'


#--> FUNCTIONS

#. calculate AC50: antilog LAC50
CalculateAC50 <- function(x){
  return(10^6*10^x)
}

#. calculate LAC50: log10(AC50/10^6)
CalculateLogAC50 <- function(x, negative=TRUE){
if (negative){
  return(-log10(x/10^6))
}
  else {
    return(log10(x/10^6))
  }
}


#-->RUN:

#. read sample ids and files
sampleIds <- read.csv(file_in_samples_ids)
sampleFiles <- sampleIds$SAMPLE_FILE
sampleUID <- sampleIds$SAMPLE_ID

#. read sample data to list
datList <- list()
for (i in 1:length(sampleFiles)){
  datList[[i]] <- read.csv(file.path(dir_in, sampleFiles[i]))
}

#. filter out incomplete and align data rows (compounds)
rowsAny <- sapply(datList, function(x) paste(x[,rowUID]))
temp <- table(rowsAny)
rowsAll <- names(temp)[temp == length(datList)]
for (i in 1:length(datList)){
  temp <- datList[[i]]
  temp <- temp[ match(rowsAll, temp[,rowUID]), ]
  datList[[i]] <- temp
}

#. write out compound ids/name to one file in processed/metadata directory
temp <- datList[[1]]
temp <- temp[, match(varCompound, colnames(temp))]
write.csv(temp, file_out_compounds_ids, row.names = FALSE, quote = TRUE)

#. write out drug doses to one file in processed/metadata directory,  
#.. assuming doses are the same across all samples for a particular drug
temp <- datList[[1]]
same_dose <- sapply(datList, function(x) all(x[,match(varDose, colnames(x))] == 
  temp[ ,match(varDose, colnames(x))]))
if (any(!same_dose))
  stop('compound doses are not the same across all treated samples')
temp <- datList[[1]]
temp <- temp[, match(c(rowUID, varDose), colnames(temp))]
write.csv(temp, file_out_doses, row.names = FALSE, quote = FALSE)

#. write out response (normalized percentage of viable cells)
#.. saves multiple files (single file per sample)
#.. in processed/drug_response/response directory
for (i in 1:length(datList)){
  temp <- datList[[i]]
  temp <- temp[ ,match(c(rowUID, varResponse), colnames(temp))]
    write.csv(temp, file.path(dir_out_response, paste(sampleUID[i], 'response.csv', sep='_')),
    row.names = FALSE, quote = TRUE)
}

#. write out drc (dose response curve fit and sensitivity estimates)
#.. saves multiple files (single file per sample)
#.. in processed/drug_response/drc directory
for (i in 1:length(datList)){
  temp <- datList[[i]]
  subAC50 <- temp[ ,subDose]
  temp <- temp[ ,match(c(rowUID, varDRC), colnames(temp))]
  AC50 <- CalculateAC50(temp[,logAC50])
  iAC50 <- ifelse(temp[ ,curveClass2] == kBadCurve & is.na(temp[ ,logAC50]), subAC50, AC50)
  iLAC50 <- CalculateLogAC50(iAC50, negative = TRUE)
  temp <- data.frame(temp, iLAC50, AC50, iAC50)
  write.csv(temp, file.path(dir_out_drc, paste(sampleUID[i], 'drc.csv', sep='_')),
    row.names = FALSE, quote = TRUE)
}
