## R script for compound sensitivity prediction

# example: Rscript prediction_algorithm_analysis.R "NCGC00013226-15" "/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv" "/data/datasets/final/regression/SuperLearner"
# args
# 1) SID for compound
# 2) feature input matrix path and file
# 3) output directory

Sys.time()
getwd()

### the location (can be a full path, or place in wd) of the bam file:
args <- commandArgs(trailingOnly = TRUE)
if(length(args) != 3) stop("script requires 3 inputs, the compound SID, the input feature matrix file, and the output directory")

drugSID <- args[1]
feature_input <- args[2] 
regression_ouput_dir <- args[3]

library(methods)
library(SuperLearner)
library(glmnet)
library(randomForest)

.libPaths()
sessionInfo()
# set seed?
# set.seed(742015)

## input data sources
drug_response_input <- "/data/datasets/filtered/drug_response/iLAC50_filtered.csv"


## load data
drugDat <- read.csv(drug_response_input, stringsAsFactors = FALSE)
colnames(drugDat)[1] <- "SID"

geneDat <- read.csv(feature_input, stringsAsFactors = FALSE) # first row is ensembl gene ID
colnames(geneDat)[1] <- "Feature" # add variable name to feature data.frame


### filtering features should be done outside this code now

# grab single compound vector
drugDat_sub <- drugDat[drugDat$SID == drugSID, ] # select single compound
if(nrow(drugDat_sub) == 0) stop("input compound SID not in data")


### transpose data to cell lines are rows and featuers are columns
### also line up cell lines in same rows
tdrugDat_sub <- as.data.frame(t(drugDat_sub[, -1]))
colnames(tdrugDat_sub) <- drugSID # use SID as name
tgeneDat <- as.data.frame(t(geneDat[, colnames(drugDat[, -1])]))
colnames(tgeneDat) <- geneDat[, 1]

# check cell lines match
if(nrow(tgeneDat) < 5) stop("less than 5 cell line names match between the compound data and the feature data")

if(!all.equal(rownames(tgeneDat), rownames(tdrugDat_sub))) stop("Cell Line order doesn't agree between compound matrix and feature matrix") # should be TRUE

### put together prediction algorithms
### some a built in, but can create custom algorithms and incorporate
# SL.glmnet
# SL.randomForest
# SL.leekasso
# SL.rpart  # see also SL.rpartPrune
# SL.svm
# SL.mean

### screening algorithms to consider?
### Thee filter features prior to running a regression algorithm
# screen.corP

SL.library <- c("SL.randomForest", "SL.glmnet", "SL.mean") # add algorithms here


Y <- tdrugDat_sub[, 1]
X <- tgeneDat[!is.na(Y), ]
Y <- Y[!is.na(Y)] # check for missing outcomes and remove
print(drugSID)
print(Y)
N <- length(Y)
out_SL <- SuperLearner(Y= Y, X = X, newX = tgeneDat, SL.library = SL.library, verbose = FALSE, cvControl = list(V = N))
save(out_SL, file = file.path(paste0(regression_ouput_dir, "/outSL_", drugSID, ".RData")))
print(out_SL)

Sys.time()

# ### can compute LOOCV R-squared values
# CVR2 <- vector("list", ncol(tdrugDat_sub))
# names(CVR2) <- colnames(tdrugDat_sub)
# for(ii in seq(ncol(tdrugDat_sub))) {
# 	load(file.path(paste0(regression_ouput_dir, "/outSL_", colnames(tdrugDat_sub)[ii], ".RData")))
# 	CVR2[[ii]] <- c("randomForest" = 1 - out_SL$cvRisk[["SL.randomForest_All"]]/out_SL$cvRisk[["SL.mean_All"]], "Glmnet" = 1 - out_SL$cvRisk[["SL.glmnet_All"]]/out_SL$cvRisk[["SL.mean_All"]], "SL.mean" = out_SL$cvRisk[["SL.mean_All"]])
# 	rm(out.SL)
# }
#
# CVR2_glmnet <- lapply(CVR2_out, function(x) x[["Glmnet"]])
# CVR2_glmnet[order(unlist(CVR2_glmnet), decreasing = TRUE)][1:20] # list top 20 based on LOOCV R2
#
# CVR2_randomForest <- lapply(CVR2_out, function(x) x[["CVR2_randomForest"]])
# CVR2_randomForest[order(unlist(CVR2_randomForest), decreasing = TRUE)][1:20]
