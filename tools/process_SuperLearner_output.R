# things to do with the SuperLearner output
#
library(SuperLearner)
library(randomForest)
library(glmnet)

load("/data/datasets/final/regression/SuperLearner/exome_variants/outSL_NCGC00346698-01.RData") # out_SL

out_SL # shows cross-validated mean squared errors

# if you want the CV mean squared error estimates directly
out_SL$cvRisk
# the syntax on the names is "SL.", "algorithm", "_", "feature subset"
# initially, running on "All" features, no subsets within super learner

## get coefficients from the elastic net
tmpCoef <- coef(out_SL$fitLibrary$SL.glmnet_All$object)[which(coef(out_SL$fitLibrary$SL.glmnet_All$object) != 0), ] # if only a single value, that is the intercept

# RandomForest estimate
out_SL$fitLibrary$SL.randomForest_All$object

# variable importance plot
varImpPlot(out_SL$fitLibrary$SL.randomForest_All$object, n.var = 10)

drug_ids = c('NCGC00345789-01', 'NCGC00346485-01', 'NCGC00346698-01', 'NCGC00262604-01', 'NCGC00346460-02', 'NCGC00346453-01', 'NCGC00345793-01', 'NCGC00187482-03', 'NCGC00263109-02', 'NCGC00159455-04', 'NCGC00345784-01', 'NCGC00250399-01')


CVR2 = vector("list", length(drug_ids))
names(CVR2) = drug_ids
for (ii in seq(length(drug_ids))){
    drugSID = drug_ids[ii]
    load(file.path(paste0(regression_ouput_dir, "/outSL_", drugSID, ".RData")))
    


# to compute the cross-validated R-squared values
# need to give in list of drugSIDs
CVR2 <- vector("list", ncol(tdrugDat_sub)) # ncol() should give number of compounds
names(CVR2) <- colnames(tdrugDat_sub) # replace with SID list
regression_output_dir = '/data/datasets/final/regression/SuperLearner/exome_variants/'
for(ii in seq(ncol(tdrugDat_sub))) {
	load(file.path(paste0(regression_ouput_dir, "/outSL_", drugSID, ".RData"))) # fix drugSID with correct file name
	CVR2[[ii]] <- c("randomForest" = 1 - out_SL$cvRisk[["SL.randomForest_All"]]/out_SL$cvRisk[["SL.mean_All"]], "Glmnet" = 1 - out_SL$cvRisk[["SL.glmnet_All"]]/out_SL$cvRisk[["SL.mean_All"]], "SL.mean" = out_SL$cvRisk[["SL.mean_All"]])
	rm(out.SL)
}

CVR2_glmnet <- lapply(CVR2_out, function(x) x[["Glmnet"]])
CVR2_glmnet[order(unlist(CVR2_glmnet), decreasing = TRUE)][1:20] # list top 20 based on LOOCV R2

CVR2_randomForest <- lapply(CVR2_out, function(x) x[["CVR2_randomForest"]])
CVR2_randomForest[order(unlist(CVR2_randomForest), decreasing = TRUE)][1:20]
