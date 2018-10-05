#' Generates a sample-wise PCA plot
#'
#' @param dat Data matrix to use
#' @param color_var Variable to color points by
#' @param scale Whether or not variables should be scaled to have unit variance
#               beore performing the PCA.
plot_sample_pca <- function(dat, color_var=NULL, color_var_name='color', point_size=4, scale=FALSE) {
    # PCA
    pca <- prcomp(t(dat), scale=scale)

    # Variance explained by each PC
    var_explained <- round(summary(pca)$importance[2,] * 100, 2)

    # Axis labels
    xl <- sprintf("PC1 (%.2f%% variance)", var_explained[1])
    yl <- sprintf("PC2 (%.2f%% variance)", var_explained[2])

    # Create a dataframe containing first two PCs
    df <- data.frame(sample_id=colnames(dat),
                     pc1=pca$x[,1], pc2=pca$x[,2])

    # Extend with color information
    if (!is.null(color_var)) {
        df[,color_var_name] <- color_var
    }

    # Generate plot
    plt <- ggplot(df, aes(pc1, pc2)) +
        geom_point(stat="identity", size=point_size) +
        geom_text(aes(label=sample_id), angle=45, size=4, vjust=2) +
        xlab(xl) + ylab(yl) +
        theme(axis.ticks=element_blank(), axis.text.x=element_text(angle=-90))

    if (!is.null(color_var)) {
        plt <- plt + geom_point(stat='identity', size=point_size, aes(color=get(color_var_name)))
    }

    plot(plt)
}

#' Filters low-count genes from an RNA-Seq count table
#' 
#' @param counts Count matrix
#' @param threshold Minimum number of reads a sample must have to contribute
#' towards filtering criterion
#' @param min_samples Minimum number of samples which have to have at least
#' `threshold` reads for the gene to be kept.
filter_low_counts <- function (counts, threshold=2, min_samples=2) {
    counts[rowSums(counts > threshold) >= min_samples,]
}
