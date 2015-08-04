#!/bin/env Rscript
###############################################################################
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
go_mapping_filepath = '/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab'
outfile             = '/data/datasets/combined/gene_ontology/go_term_zscores.csv'

# Load expression z-scores
zscores = read.csv(zscores_filepath, row.names=1)

# Load GO terms
go_mapping = tbl_df(read.delim(go_mapping_filepath))

# Output dataframe
column_labels = c('sample')
output = data.frame(sample=colnames(zscores), stringsAsFactors=FALSE)

for (go_id in unique(go_mapping$GO)) {
    # Get subset of genes associated with the GO term
    gene_ids = as.character((go_mapping %>% filter(GO == go_id))$ENSEMBL)
    gene_zscores = zscores[rownames(zscores) %in% gene_ids,]

    print(sprintf("Processing %s", go_id))

    # sum the positive and negative z-scores for each annotation
    pos_scores = apply(gene_zscores, 2, function(x) { sum(x[x > 0]) })
    neg_scores = apply(gene_zscores, 2, function(x) { sum(x[x < 0]) })
    ratio_pos  = apply(gene_zscores, 2, function(x) { sum(x > 0) / length(x) })

    column_labels = append(column_labels, 
                           c(paste0(c(sub(':', '_', go_id), 'pos'), collapse='_'),
                             paste0(c(sub(':', '_', go_id), 'neg'), collapse='_'),
                             paste0(c(sub(':', '_', go_id), 'pct_pos'), collapse='_')))

    output = cbind(output, pos_scores, neg_scores, ratio_pos)
}

colnames(output) = column_labels

# drop sample column and output
output = output[,-c(1)]

if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)    
}
write.csv(output, quote=FALSE, file=outfile)

