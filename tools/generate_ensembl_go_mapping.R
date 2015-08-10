#!/bin/env Rscript
###############################################################################
#
# prepare_go.R
#
# Generates a gene / GO term mapping
#
# Usage:
#
#    Rscript generate_ensembl_go_mapping.R {output file}
#
# Keith Hughitt
# 2015/08/03
#
###############################################################################
library('Homo.sapiens')

args = commandArgs(TRUE)
outfile = args[1]

# Create mapping
go_terms = AnnotationDbi::select(Homo.sapiens, keytype='ENSEMBL',
                          keys=keys(Homo.sapiens, keytype='ENSEMBL'),
                          columns=c("GO"))

# Add GO term names
go_term_names = AnnotationDbi::select(GO.db, go_terms$GO, "TERM", "GOID")
go_terms$TERM = go_term_names$TERM[match(go_terms$GO, go_term_names$GOID)]

# Remove redundant annotations which differ only in source/evidence and drop
# entries with NAs
gene_go_mapping = unique(go_terms[complete.cases(go_terms),])

# Save output
write.table(gene_go_mapping, quote=FALSE, sep='\t', 
            row.names=FALSE, file=outfile)

