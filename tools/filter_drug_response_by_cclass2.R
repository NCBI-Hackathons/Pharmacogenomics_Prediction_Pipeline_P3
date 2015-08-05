#!/bin/env Rscript
###############################################################################
#
# drug_response data preparation
# Aleksandra Michalowski
# 2015/08/04
#
# This script filters drugs based on curve class
# 
# 
# The steps performed are:
# 
# 1. read raw data (drug sensitivity estimates)
# 2. select drugs if CCLASS == -1.1 in at least 5 cell lines 
# 3. write .csv files with filtered data
#
###############################################################################


rm(list=ls())
setwd('/data/datasets/raw/drug_response')

fils <- list.files()
ldat <- vector('list', length(fils))
names(ldat) <- sub(".\\csv", "", fils)
for(i in 1:length(fils))
ldat[[i]] <- read.csv(fils[i], row=1)

find.clas <- names(ldat) == 'CCLASS2'
clas <- ldat[[which(find.clas)]]
cond <- apply(clas, 1, function(x) sum(x == -1.1))
sel <- cond >= 5
store <- '/data/datasets/filtered/drug_response'
for (i in 1:length(ldat))
    {
    dat <- ldat[[i]][sel,]
    nam <- names(ldat)[i]
    write.csv(dat, file.path(store,paste(nam,'filtered.csv',sep='_')))
}


setwd(store)
fils <- list.files()
ldat <- vector('list', length(fils))
names(ldat) <- sub(".\\csv", "", fils)
for(i in 1:length(fils))
ldat[[i]] <- read.csv(fils[i], row=1)
