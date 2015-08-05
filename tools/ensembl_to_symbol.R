library(Homo.sapiens)

# given a list of ensembl IDs, convert to gene symbol.
tosymbol = function(ensembl){
    select(Homo.sapiens, keys=ensembl, keytype="ENSEMBL", columns=c('SYMBOL'))$SYMBOL
}
