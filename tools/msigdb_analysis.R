#!/bin/env Rscript
###############################################################################
#
# msigdb_analysis.R
#
# Ryan Dale
# 2015/08/05
#
#
# Modified from:
#
# go_term_analysis.R
#
# Keith Hughitt <khughitt@umd.edu>
# 2015/08/04
#
# Looks for GO terms which are over- or under-represented among DE genes,...
#
###############################################################################
library('dplyr')

# Filepaths
zscores_filepath    = '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv'
msigdb_mapping_filepath = '/data/datasets/raw/msig_db/c2.cp.v5.0.ensembl.tab'
outfile             = '/data/datasets/combined/msig_db/msig_db_zscores.csv'

# Load expression z-scores
zscores = read.csv(zscores_filepath, row.names=1)

# Load MSIGDB terms
msigdb_mapping = tbl_df(read.delim(msigdb_mapping_filepath, col.names=c('ENSEMBL', 'PATHWAY')))

# Output dataframe
column_labels = c('sample')
output = data.frame(sample=colnames(zscores), stringsAsFactors=FALSE)

for (msigdb_id in unique(msigdb_mapping$PATHWAY)) {
    # Get subset of genes associated with the pathway
    gene_ids = as.character((msigdb_mapping %>% filter(PATHWAY == msigdb_id))$ENSEMBL)
    gene_zscores = zscores[rownames(zscores) %in% gene_ids,]

    print(sprintf("Processing %s", msigdb_id))

    # sum the positive and negative z-scores for each annotation
    pos_scores = apply(gene_zscores, 2, function(x) { sum(x[x > 0]) })
    neg_scores = apply(gene_zscores, 2, function(x) { sum(x[x < 0]) })
    ratio_pos  = apply(gene_zscores, 2, function(x) { sum(x > 0) / length(x) })

    column_labels = append(column_labels, 
                           c(paste0(c(sub(':', '_', msigdb_id), 'pos'), collapse='_'),
                             paste0(c(sub(':', '_', msigdb_id), 'neg'), collapse='_'),
                             paste0(c(sub(':', '_', msigdb_id), 'pct_pos'), collapse='_')))

    output = cbind(output, pos_scores, neg_scores, ratio_pos)
}

colnames(output) = column_labels

# drop sample column and output
output = output[,-c(1)]

if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)    
}
write.csv(output, quote=FALSE, file=outfile)

