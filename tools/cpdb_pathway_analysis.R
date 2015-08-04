#!/bin/env Rscript
###############################################################################
#
# cpdb_pathway_analysis.R
#
# Keith Hughitt <khughitt@umd.edu>
# 2015/08/04
#
# Looks for CPDB pathways which are over- or under-represented among DE genes.
#
###############################################################################
library('dplyr')

# Filepaths
zscores_filepath    = '/data/datasets/filtered/rnaseq_expression/HMCL_ensembl74_Counts_zscore.csv'
cpdb_mapping_filepath = '/data/datasets/raw/consensus_pathway_db/CPDB_pathways_genes.tab'
outfile             = '/data/datasets/combined/consensus_pathway_db/cpdb_pathway_zscores.csv'

# Load expression z-scores
zscores = read.csv(zscores_filepath, row.names=1)

# Load CPDB pathways
cpdb_mapping = tbl_df(read.delim(cpdb_mapping_filepath))

# For now, ignore rows with duplicated pathways ids
#> length(cpdb_mapping$external_id) - length(unique(cpdb_mapping$external_id))
#[1] 28
cpdb_mapping = cpdb_mapping[!duplicated(cpdb_mapping$external_id),]

# Output dataframe
column_labels = c('sample')
output = data.frame(sample=colnames(zscores), stringsAsFactors=FALSE)

for (cpdb_id in unique(cpdb_mapping$external_id)) {
    # Get subset of genes associated with the CPDB pathway
    entry = cpdb_mapping %>% filter(external_id == cpdb_id)
    gene_ids = unlist(strsplit(as.character(entry$ensembl_ids), ','))

    gene_zscores = zscores[rownames(zscores) %in% gene_ids,]

    print(sprintf("Processing %s", cpdb_id))

    # sum the positive and negative z-scores for each annotation
    pos_scores = apply(gene_zscores, 2, function(x) { sum(x[x > 0]) })
    neg_scores = apply(gene_zscores, 2, function(x) { sum(x[x < 0]) })
    ratio_pos  = apply(gene_zscores, 2, function(x) { sum(x > 0) / length(x) })

    column_labels = append(column_labels, 
                           c(paste0(c(sub(':', '_', cpdb_id), 'pos'), collapse='_'),
                             paste0(c(sub(':', '_', cpdb_id), 'neg'), collapse='_'),
                             paste0(c(sub(':', '_', cpdb_id), 'pct_pos'), collapse='_')))

    output = cbind(output, pos_scores, neg_scores, ratio_pos)
}

colnames(output) = column_labels

# drop sample column and output
output = output[,-c(1)]

if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)    
}
write.csv(output, quote=FALSE, file=outfile)

