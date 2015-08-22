#!/usr/bin/Rscript
#
# Creates a BED file of transcript start/stop coords
suppressMessages(library(Homo.sapiens))

args = commandArgs(TRUE)
x = select(
           Homo.sapiens,
           keys=keys(Homo.sapiens, keytype='ENSEMBL'),
           keytype='ENSEMBL',
           columns=c('TXCHROM', 'TXSTART', 'TXEND'))


write.table(
            x[!is.na(x$TXCHROM), c('TXCHROM', 'TXSTART', 'TXEND', 'ENSEMBL')],
            row.names=FALSE,
            col.names=FALSE,
            file=args[1],
            sep='\t', quote=FALSE)
