#' 
#' Takes a vector of filepaths to RData SuperLearner output from a P3 run
#' and generates a list containing a few useful summary data structures.
#'
#' @author Keith Hughitt <khughitt@umd.edu>
#'
#' @param infiles Vector of RData results files
#' @return List of parsed SuperLearner learners, broken up into three parts:
#          learn coefficients, cross-validation risks, and random forest
#          variable importance.
parse_p3_results <- function(infiles) {
    # create placeholder variables
    drugs           <- c()
    coefs           <- NA
    cv_risks        <- NA
    var_importance  <- NA
    prediction_var  <- c()

    # iterate over P3 outputs
    for (i in 1:length(infiles)) {
        # load result
        infile <- infiles[i]
        message(sprintf("Loading %s.", infile))
        load(infile)

        # drug name
        drug <- sub('.RData', '', basename(infile))
        drugs <- c(drugs, drug)

        # prediction variance
        prediction_var <- c(prediction_var, var(out.SL$SL.predict[,1]))

        # random forest variable importantce
        importance <- out.SL$fitLibrary$SL.randomForest_All$object$importance

        # update outputs
        if (i == 1) {
            # on first iteration of loop, overwrite placeholder variables
            coefs    <- out.SL$coef
            cv_risks <- out.SL$cvRisk
            var_importance <- importance
        } else {
            coefs    <- rbind(coefs, out.SL$coef)
            cv_risks <- rbind(cv_risks, out.SL$cvRisk)
            var_importance <- cbind(var_importance, importance)
        }
    }
    colnames(var_importance) <- drugs
    colnames(coefs) <- sub('_All', '', sub('SL.', '', colnames(coefs)))
    colnames(cv_risks) <- sub('_All', '', sub('SL.', '', colnames(cv_risks)))
    rownames(coefs) <- drugs
    rownames(cv_risks) <- drugs

    list(
        coefs=coefs,
        cv_risks=cv_risks,
        var_importance=var_importance
    )
}

#'
#' Outputs an HTML datatable with all rows or static pandoc-friendly table with
#' a limited set of rows depending on the current output target.
#'
#' @author Keith Hughitt <khughitt@umd.edu>
#'
#' This function requires that the document requires that the knitr script is
#' being generated using the rmarkdown `render` function.
#'
#' @param dat Data to display
#' @param nrows Maximum number of rows to show
#' @param caption Caption to use for table (optional)
#' @param digits Number of digits to disply for numeric
#' @param datatable_theme Theme to use when rendering the table with datatable
#'
xkable <- function (dat, nrows=15, caption=NULL, digits=getOption("digits"), 
                    str_max_width=Inf, datatable_style='bootstrap') {
    # Trim strings if desired
    if (str_max_width < Inf) {
        str_cols <- vapply(dat, is.character, FUN.VALUE=logical(1))
        # Iterate over character columns
        for (cname in colnames(dat)[str_cols]) {
            # For all entries that exceed the maximum width, trim
            exceeds_length <- nchar(dat[[cname]]) > str_max_width
            exceeds_length[is.na(exceeds_length)] <- FALSE
            dat[[cname]][exceeds_length] <- paste0(strtrim(dat[[cname]][exceeds_length], 
                                                           str_max_width - 3), '...')

        }
    }

    # Determine output format to use
    if (is.null(opts_knit$get("rmarkdown.pandoc.to"))) {
        # Default to latex output (kable)
        output_format <- 'latex'
    } else {
        output_format <- opts_knit$get("rmarkdown.pandoc.to") 
    }

    # Round numeric columns
    numeric_cols <- vapply(dat, is.numeric, FUN.VALUE=logical(1))
    dat[,numeric_cols] <- round(dat[,numeric_cols], digits)

    # HTML output
    if (nrow(dat) > nrows && output_format == 'html') {
        datatable(dat, style=datatable_style, caption=caption, 
                  options=list(pageLength=nrows))
    } else {
        # Static output
        kable(head(dat, nrows), caption=caption)
    }
}

#'
#' Creates a mapping from P3 features to human-readable descriptions for those
#' features.
#'
#' @author Keith Hughitt <khughitt@umd.edu>
#'
#' This function takes a list of mixed feature identifiers as they appear in
#' the P3 results (gene IDs, GO terms, etc.), and assigns a human-readable
#' description is each case where it is possible.
#'
#' @param features Vector of P3 feature names, e.g. 'go_zscores_GO_0036464_mean_pos'
#' @return Vector of feature descriptions (currently limited to ENSEMBL/GO
#' features)
get_feature_descriptions <- function(features) {
    # Vector to store descriptions
    descriptions <- rep('', length(features))

    #
    # ENSEMBL gene descriptions
    #
    get_ensembl_description <- function (features) {
        # extract ENSEMBL IDs from feature names
        extract_ensembl_id <- function (x) { 
            unlist(strsplit(x, '_')) %>% last
        }
        ensembl_ids <- sapply(features, extract_ensembl_id)

        # retrieve gene descriptions from org.Hs.eg.db and return them
        # `mapIds` behaves similar to `select` but accepts only one column
        # and returns the first match for each query id.
        mapIds(org.Hs.eg.db, keys=ensembl_ids, keytype='ENSEMBL', 
               column="GENENAME")
    }
    descriptions[grepl('ENSG', features)] <- get_ensembl_description(features[grepl('ENSG', features)])

    #
    # GO term descriptions
    #
    get_go_description <- function (features) {
        # extract GO IDs from feature names
        extract_go_id <- function (x) { 
            sub('_', ':', str_match(x, 'GO_[0-9]+'))
        }
        go_ids <- sapply(features, extract_go_id)

        # retrieve GO term descriptions and return them
        select(GO.db, go_ids, columns='TERM')$TERM
    }
    descriptions[grepl('_GO_', features)] <- get_go_description(features[grepl('_GO_', features)])

    # return feature descriptions
    return(descriptions)
}

