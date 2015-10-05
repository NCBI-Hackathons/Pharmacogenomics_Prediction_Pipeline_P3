# Args:
#   - file containing features. Rows are samples, columns are features. These
#     are expected to already be filtered.
#   - file containing compound response data. Rows are samples, columns are
#     compounds. Only one compound will be extracted from this matrix.
#   - SID of compound
#   - Output file
#
# Features are expected to be already filtered and to have unique rownames.
#
# Output is an .RData file containing the learned parameters to be used in downstream
# processing.

Sys.time()
getwd()
args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 5) stop("Script needs 4 inputs: features, response, SID, SL.library.file, output. See script for details")

features.file <- args[1]
response.file <- args[2]
sid <- args[3]
SL.library.file <- args[4]
output.file <- args[5]

if (!file.exists(features.file)) stop(paste("Can't find", features.file))
if (!file.exists(response.file)) stop(paste("Can't find", response.file))
if (!file.exists(SL.library.file)) stop(paste("Can't find", SL.library.file))

library(methods)
library(SuperLearner)
library(glmnet)
library(randomForest)
.libPaths()
sessionInfo()

# Rows are expected to be samples in both cases.
response.data <- read.table(
    response.file, row.names=1, sep='\t', header=TRUE, stringsAsFactors=FALSE)
feature.data <- read.table(
    features.file, row.names=1, sep="\t", header=TRUE, stringsAsFactors=FALSE)

if (!all.equal(rownames(response.data), rownames(feature.data))) stop("Samples don't match between features and response")

# For Y we only use a single column of the response data.
Y <- response.data[sid]
if (is.null(Y)) stop(paste0("requested ID, ", sid, ", not in response data"))

# The filtering step should have removed NAs, but do it here just to be sure.
valid.Y <- !is.na(Y)
if (sum(!valid.Y) > 0) warning("NAs found in Y; you may want to remove these in the filtering stage")
X <- feature.data[valid.Y, ]
Y <- Y[valid.Y]
N <- length(Y)

# This file is required to create SL.library, which is then passed to
# SuperLearner() below.
source(SL.library.file)
if (!exists(SL.library)) stop(paste("SL.library.file", SL.library.file, "did not create a variable called 'SL.library'"))

# Use full feature data frame (possibly including NAs) as newX.
out.SL <- SuperLearner(Y=Y, X=X, newX=feature.data, SL.library=SL.library,
                       verbose=TRUE, cvControl=list(V=N))

save(out.SL, file=output.file)
print(out.SL)
Sys.time()
