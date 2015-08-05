## R script for compound sensitivity prediction

# example: Rscript prediction_algorithm_analysis.R "NCGC00013226-15"
Sys.time()
getwd()

### the location (can be a full path, or place in wd) of the bam file:
args <- commandArgs(trailingOnly = TRUE)
if(length(args) != 1) stop("script requires 1 input, the compound SID")

drugSID <- args[1]

library(SuperLearner)
library(glmnet)
library(randomForest)

# set seed?
# set.seed(742015)

## input data sources
rnaseq_input <- "/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_normalized.csv"
drug_response_input <- "/data/datasets/filtered/drug_response/iLAC50_filtered.csv"

## output dir, move as appropriate
regression_ouput_dir <- "/data/datasets/final/regression/SuperLearner"

## load data
drugDat <- read.csv(drug_response_input, stringsAsFactors = FALSE)
colnames(drugDat)[1] <- "SID"

geneDat <- read.csv(rnaseq_input, stringsAsFactors = FALSE) # first row is ensembl gene ID
colnames(geneDat)[1] <- "EnsemblGene" # add variable name to genes

# dim(drugDat)
# dim(geneDat)
# setdiff(colnames(drugDat), colnames(geneDat))
# setdiff(colnames(geneDat), colnames(drugDat))


## filtering features
### remove any compounds?
# DrugRange <- apply(drugDat[, -1], 1, function(xx) diff(range(xx, na.rm = TRUE)))

drugDat_sub <- drugDat[drugDat$SID == drugSID, ] # select single compound
if(nrow(drugDat_sub) == 0) stop("input compound SID not in data")

### filter genes?
geneSD <- apply(geneDat[, colnames(drugDat)[-1]], 1, sd, na.rm = TRUE)
sum(geneSD > 2) # using 2 as example, may want to lower threshold
geneDat_sub <- geneDat[which(geneSD > 2), ]

### transpose data to cell lines are rows and featuers are columns
### also line up cell lines in same rows
tdrugDat_sub <- as.data.frame(t(drugDat_sub[, -1]))
colnames(tdrugDat_sub) <- drugSID # use SID as name
tgeneDat_sub <- as.data.frame(t(geneDat_sub[, colnames(drugDat_sub[, -1])]))
colnames(tgeneDat_sub) <- geneDat_sub[, 1]

# check cell lines match
all.equal(rownames(tgeneDat_sub), rownames(tdrugDat_sub)) # should be TRUE

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
X <- tgeneDat_sub[!is.na(Y), ]
Y <- Y[!is.na(Y)] # check for missing outcomes and remove
N <- length(Y)
out_SL <- SuperLearner(Y= Y, X = X, newX = tgeneDat_sub, SL.library = SL.library, verbose = FALSE, cvControl = list(V = N))
save(out_SL, file = file.path(paste0(regression_ouput_dir, "/outSL_", drugSID, ".RData")))
print(out_SL)

sessionInfo()
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
