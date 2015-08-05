#######################################################
## Statistical Summary and Plots of Drug Response Data
## Fay Wong, Aug. 5, 2015
#######################################################


setwd("/data/datasets/filtered/drug_response/")
## for all files under directory /data/datasets/raw/drug_response/
## AC50.csv  CCLASS2.csv  FAUC.csv  iAC50.csv  iLAC50.csv  LAC50.csv  MAXR.csv  TAUC.csv
## for all files under directory /data/datasets/filtered/drug_response/
## AC50_filtered.csv     FAUC_filtered.csv   iLAC50_filtered.csv  MAXR_filtered.csv
## CCLASS2_filtered.csv  iAC50_filtered.csv  LAC50_filtered.csv   TAUC_filtered.csv

ngs_file_handle = "iAC50_filtered.csv"
nchar(ngs_file_handle)
ngs_file= substr(ngs_file_handle, 0, nchar(ngs_file_handle)-4)

## row = 1: assign the first column as the row name
ngs_table=read.table(ngs_file_handle,header=T, sep=',', as.is=T, row=1)

#summary(ngs_table)
#head(ngs_table[1,])
#summary(t(ngs_table))
#head(t(ngs_table))
#dim(ngs_table)

## Write summary statistics table for Drug Response data
write.table(summary(t(ngs_table)), file=paste(ngs_file,'_summary.txt'),sep="\t") 

## Draw plots for Drug Responses based on Cell Line and Drug 
png(paste(ngs_file,"_CellLine.png"), width=2160, height=1520, units = "px")
boxplot(ngs_table)
dev.off()
png(paste(ngs_file,"_Drug.png"), width=2160, height=1520, units = "px")
boxplot(t(ngs_table))
dev.off()


