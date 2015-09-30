#!/bin/env Rscript
###############################################################################################
#
#  drug response data preparation
# 
#  ammhub
#  2015/09/28
#
# This script reads NCATS default output files (single file per sample)
# 
# The steps performed are:
#   
#   1. calculates AC50 (back from log AC50); adds variable named AC50
#   2. assigns highest dose to missing AC50 if class curve2 equals 4; adds variable named iAC50
#   3. calculates negative log with iAC50: adds variable named iLAC50
#   4. splits data and writes out different type of data (single file per sample):
#      - compound ids/names
#      - compound doses 
#      - response data (normalized percentage of viable cells)
#      - drc (dose response curve fit and sensitivity estimates)
##################################################################################################



#--> CATCH snakemake arguments
args <- commandArgs(trailingOnly = TRUE)
args_names <- c("input", "drugIds_file", "drugResponse_file", "drugDoses_file", "drugDrc_file", "rowUid")
for(i in 1:length(args)) assign(args_names[i], args[i])

#input <- 'example_data/raw/drug_response/s-tum-LineA_1-x1-1.csv'
#drugIds_file <- 'example_data/processed/drug_response/ids/s-tum-LineA_1-x1-1_drugIds.tab'
#drugDoses_file <- 'example_data/processed/drug_response/doses/s-tum-LineA_1-x1-1_drugDoses.tab'
#drugResponse_file <- 'example_data/processed/drug_response/response/s-tum-LineA_1-x1-1_drugResponse.tab'
#drugDrc_file <- 'example_data/processed/drug_response/drc/s-tum-LineA_1-x1-1_drugDrc.tab'
#rowUid <- 'SID'



#--> HARD CODED: options/parameters

#. variable names for splitting data by content
varCompound <- c('readout', 'name', 'target', 'smi')
varDrc <- c('NPT', 'CCLASS', 'CCLASS2', 'HILL', 'INF', 'ZERO', 'MAXR', 'TAUC', 'FAUC', 'LAC50')
varDoses <- paste('C', 0:10, sep='')
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



#--> RUN

#. read in data
print(input)
datIn <- read.csv(file = input)

#. write out drug ids (compounds)
drugIds <- datIn[,c(rowUid, varCompound)]
write.table(drugIds, file = drugIds_file, row.names = FALSE, quote = TRUE, sep='\t')

#. write out drug doses to one file in processed/metadata directory,  
drugDoses <- datIn[,c(rowUid, varDoses)]
write.table(drugDoses, file = drugDoses_file, row.names = FALSE, quote = TRUE, sep='\t')

#. write out response (normalized percentage of viable cells)
drugResponse <- datIn[,c(rowUid, varResponse)]
write.table(drugResponse, file = drugResponse_file, row.names = FALSE, quote = TRUE, sep='\t')

#. calculate and write out dose response curve estimates
temp <- datIn
subAC50 <- temp[ ,subDose]
temp <- temp[ c(rowUid, varDrc)]
AC50 <- CalculateAC50(temp[,logAC50])
iAC50 <- ifelse(temp[ ,curveClass2] == kBadCurve & is.na(temp[ ,logAC50]), subAC50, AC50)
iLAC50 <- CalculateLogAC50(iAC50, negative = TRUE)
temp <- data.frame(temp, iLAC50, AC50, iAC50)
write.table(temp, file = drugDrc_file,  row.names = FALSE, quote = TRUE, sep='\t')
