## FAUC
get.auc <- function (params, xmin, xmax) {
  if (is.null(params) || !is.list(params))
    stop("Must supply a named list of fit parameters")
  attach(params)
  f <- function(xx) zero + (inf - zero)/(1 + 10^((lac50 - xx) * hill))
  v <- integrate(f, lower = xmin, upper = xmax)
  detach(params)
  return(v)
}

## TAUC

get.auc.trapezoidal <- function (x, y)
{
    idx = 2:length(x)
    return(as.double((x[idx] - x[idx - 1]) %*% (y[idx] + y[idx - 1]))/2)
}
