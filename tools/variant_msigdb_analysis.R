#!/bin/env Rscript
###############################################################################
#
# variant_msigdb_analysis.R
#
# Authors: Ryan Dale and Keith Hughitt <khughitt@umd.edu>
# 2015/08/04
#
# Counts the number of SNPs found in MSigDB pathways.
#
###############################################################################
library('dplyr')

# Filepaths
variants_filepath       = '/data/datasets/filtered/exome_variants/genes_per_cell_line.txt'
msigdb_mapping_filepath = '/data/datasets/raw/msig_db/c2.cp.v5.0.ensembl.tab'
outfile                 = '/data/datasets/combined/msig_db/msig_db_variants.csv'

# Load exome data
variants = read.delim(variants_filepath, row.names=1)

# Load MSIGDB terms
msigdb_mapping = tbl_df(read.delim(msigdb_mapping_filepath, col.names=c('ENSEMBL', 'PATHWAY')))

# Output dataframe
column_labels = c('sample')
output = data.frame(sample=colnames(variants), stringsAsFactors=FALSE)

for (msigdb_id in unique(msigdb_mapping$PATHWAY)) {
    # Get subset of genes associated with the pathway
    gene_ids = as.character((msigdb_mapping %>% filter(PATHWAY == msigdb_id))$ENSEMBL)
    gene_variants = variants[rownames(variants) %in% gene_ids,]

    print(sprintf("Processing %s", msigdb_id))

    # Number of SNPs in the category
    num_snps = colSums(gene_variants)

    column_labels = append(column_labels, 
                           paste0(c(sub(':', '_', msigdb_id), 'num_snps'), collapse='_'))
    output = cbind(output, num_snps)
}

colnames(output) = column_labels

# drop sample column and output
output = output[,-c(1)]

if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)    
}
write.csv(output, quote=FALSE, file=outfile)

