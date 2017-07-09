library(glmnet)
library(rpart)
library(SuperLearner)
library(gbm)
library(gplots)
library(mboost)
######## Now fit the regression models
# SL.glmnet1se <- function(...) SL.glmnet(..., useMin = FALSE)
SL.rpartPrune2 <- function(..., cp = 0.001, minsplit = 10, maxdepth = 3, xval = 20, minbucket = 4) SL.rpartPrune(..., cp = cp, minsplit = minsplit, xval = xval, maxdepth = maxdepth, minbucket = minbucket)

SL.gbmOOB <- function(Y, X, newX, family, obsWeights, gbm.trees = 1000, interaction.depth = 2, ...) 
{
    require("gbm")
    gbm.model <- as.formula(paste("Y~", paste(colnames(X), collapse = "+")))
    if (family$family == "gaussian") {
        fit.gbm <- gbm(formula = gbm.model, data = X, distribution = "gaussian", 
            n.trees = gbm.trees, interaction.depth = interaction.depth, 
            cv.folds = 0, keep.data = TRUE, weights = obsWeights, 
            verbose = FALSE)
    }
    if (family$family == "binomial") {
        fit.gbm <- gbm(formula = gbm.model, data = X, distribution = "bernoulli", 
            n.trees = gbm.trees, interaction.depth = interaction.depth, 
            cv.folds = 0, keep.data = TRUE, verbose = FALSE, 
            weights = obsWeights)
    }
    best.iter <- gbm.perf(fit.gbm, method = "OOB", plot.it = FALSE)
    pred <- predict(fit.gbm, newdata = newX, best.iter, type = "response")
    fit <- list(object = fit.gbm, n.trees = best.iter)
    out <- list(pred = pred, fit = fit)
    class(out$fit) <- c("SL.gbm")
    return(out)
}
SL.glmboost <- function(Y, X, newX, family, obsWeights, mstop = 1000, centerBoost = FALSE, ...) 
{
    require("mboost")
    if (family$family == "gaussian") {
        fit.gbm <- glmboost(y = Y, x = as.matrix(X), family = GaussReg(), control = boost_control(mstop = mstop, nu = 0.1, risk = "inbag"), center = centerBoost)
    }
    if (family$family == "binomial") {
        stop("not yet implemented")
    }
    pred <- predict(fit.gbm, newdata = as.matrix(newX), type = "response")
    fit <- list(object = fit.gbm)
    out <- list(pred = pred, fit = fit)
    class(out$fit) <- c("SL.glmboost")
    return(out)
}
predict.SL.glmboost <- function(object, newdata, family, ...) {
  require("mboost")
  if (family$family == "binomial") stop("not yet implemented")
  pred <- predict(object$object, newdata = as.matrix(newdata), type = "response")
  return(pred)
}
create.SL.glmnet <- function(alpha = c(0.05, 0.25, 0.50, 0.75)) {
  for(mm in seq(length(alpha))){
    eval(parse(text = paste('SL.glmnet.', alpha[mm], '<- function(..., alpha = ', alpha[mm], ') SL.glmnet(..., alpha = alpha)', sep = '')), envir = .GlobalEnv)
  }
  invisible(TRUE)
}
create.SL.glmnet()
screen.corRank5 <- function(..., rank = 5) screen.corRank(..., rank = rank)
screen.corRank10 <- function(..., rank = 10) screen.corRank(..., rank = rank)
screen.corRank20 <- function(..., rank = 20) screen.corRank(..., rank = rank)


SL.library <- list(c("SL.gbmOOB", "All", "screen.corRank10", "screen.corRank20"), 
  c("SL.glmboost", "All", "screen.corRank10", "screen.corRank20"), 
  c("SL.ipredbagg", "All", "screen.corRank10", "screen.corRank20"), 
  c("SL.mean", "All"), 
  c("SL.glmnet", "All", "screen.corRank20"), 
  c("SL.glmnet.0.75", "All", "screen.corRank20"),
  c("SL.glmnet.0.5", "All", "screen.corRank20"), 
  c("SL.glmnet.0.25", "All", "screen.corRank20"), 
  c("SL.glmnet.0.05", "All", "screen.corRank20"), 
  c("SL.rpartPrune2", "All", "screen.corRank10", "screen.corRank20"), 
  c("SL.randomForest", "All", "screen.corRank10", "screen.corRank20"), 
  c("SL.glm", "screen.corRank5", "screen.corRank10", "screen.corRank20"),
  c("SL.nnet", "screen.corRank5", "screen.corRank10", "screen.corRank20"),
  c("SL.svm", "screen.corRank5", "screen.corRank10", "screen.corRank20"))

