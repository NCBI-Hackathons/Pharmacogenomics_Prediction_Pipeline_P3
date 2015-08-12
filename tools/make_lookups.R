#!/usr/bin/env Rscript

# Use the Homo.sapiens OrganismDbi to generate a tab-delimited lookup table
# for use by downstream tools.
#
# Usage:
#
#   make_ensembl_lookup.R <COLUMNS> <OUTPUT>
#
# where COLUMNS is a value from columns(Homo.sapiens) -- e.g., "SYMBOL" -- and
# OUTPUT is the file to create.
#
# Ryan Dale 2015/08/09
#
library(Homo.sapiens)
args = commandArgs(TRUE)
write.table(
  select(
    Homo.sapiens,
    keys=keys(Homo.sapiens, keytype='ENSEMBL'),
    keytype='ENSEMBL',
    columns=args[1]),
  file=args[2], sep='\t', row.names=FALSE, quote=FALSE)
