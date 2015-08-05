#!/bin/env Rscript
###############################################################################
#
# variant_cpdb_pathway_analysis.R
#
# Keith Hughitt <khughitt@umd.edu>
# 2015/08/04
#
# Looks for CPDB pathways which are over- or under-represented among DE genes.
#
###############################################################################
library('dplyr')

# Filepaths
variants_filepath     = '/data/datasets/filtered/exome_variants/genes_per_cell_line.txt'
cpdb_mapping_filepath = '/data/datasets/raw/consensus_pathway_db/CPDB_pathways_genes.tab'
outfile               = '/data/datasets/combined/consensus_pathway_db/cpdb_pathway_variants.csv'

# Load exome data
variants = read.delim(variants_filepath, row.names=1)

# Load CPDB pathways
cpdb_mapping = tbl_df(read.delim(cpdb_mapping_filepath))

# For now, ignore rows with duplicated pathways ids
#> length(cpdb_mapping$external_id) - length(unique(cpdb_mapping$external_id))
#[1] 28
cpdb_mapping = cpdb_mapping[!duplicated(cpdb_mapping$external_id),]

# Output dataframe
column_labels = c('sample')
output = data.frame(sample=colnames(variants), stringsAsFactors=FALSE)

for (cpdb_id in unique(cpdb_mapping$external_id)) {
    # Get subset of genes associated with the CPDB pathway
    entry = cpdb_mapping %>% filter(external_id == cpdb_id)
    gene_ids = unlist(strsplit(as.character(entry$ensembl_ids), ','))

    gene_variants = variants[rownames(variants) %in% gene_ids,]

    print(sprintf("Processing %s", cpdb_id))

    # Number of SNPs in the category
    num_snps = colSums(gene_variants)

    column_labels = append(column_labels, 
                           paste0(c(sub(':', '_', cpdb_id), 'num_snps'), collapse='_'))
    output = cbind(output, num_snps)
}

colnames(output) = column_labels

# drop sample column and output
output = output[,-c(1)]

if (!dir.exists(dirname(outfile))) {
    dir.create(dirname(outfile), recursive=TRUE)    
}
write.csv(output, quote=FALSE, file=outfile)

