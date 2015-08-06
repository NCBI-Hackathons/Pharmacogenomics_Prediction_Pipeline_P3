library(Homo.sapiens)

# given a list of ensembl IDs, convert to gene symbol.
tosymbol = function(ensembl){
    select(Homo.sapiens, keys=ensembl, keytype="ENSEMBL", columns=c('SYMBOL'))$SYMBOL
}

drug_ids = c('NCGC00345789-01', 'NCGC00346485-01', 'NCGC00346698-01', 'NCGC00262604-01', 'NCGC00346460-02', 'NCGC00346453-01', 'NCGC00345793-01', 'NCGC00187482-03', 'NCGC00263109-02', 'NCGC00159455-04', 'NCGC00345784-01', 'NCGC00250399-01')

