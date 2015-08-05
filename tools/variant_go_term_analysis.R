#!/bin/env Rscript
###############################################################################
#
# variant_go_term_analysis.R
#
# Keith Hughitt <khughitt@umd.edu>
# 2015/08/05
#
# Summarizes presence of SNPs among different GO terms.
#
###############################################################################
library('dplyr')

# Filepaths
variants_filepath    = '/data/datasets/filtered/exome_variants/genes_per_cell_line.txt'
go_mapping_filepath = '/data/datasets/raw/gene_ontology/ensembl_go_mapping.tab'
outfile             = '/data/datasets/combined/gene_ontology/go_term_variants.csv'

# Load exome data
variants = read.delim(variants_filepath, row.names=1)

# Load GO terms
go_mapping = tbl_df(read.delim(go_mapping_filepath))

# Output dataframe
column_labels = c('sample')
output = data.frame(sample=colnames(variants), stringsAsFactors=FALSE)

for (go_id in unique(go_mapping$GO)) {
    # Get subset of genes associated with the GO term
    gene_ids = as.character((go_mapping %>% filter(GO == go_id))$ENSEMBL)
    gene_variants = variants[rownames(variants) %in% gene_ids,]

    print(sprintf("Processing %s", go_id))

    # Number of SNPs in the category
    num_snps = colSums(gene_variants)

    column_labels = append(column_labels, 
                           paste0(c(sub(':', '_', go_id), 'num_snps'), collapse='_'))
    output = cbind(output, num_snps)
}

colnames(output) = column_labels

# drop sample column and output
output = output[,-c(1)]

if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)    
}
write.csv(output, quote=FALSE, file=outfile)

