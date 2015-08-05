# findRegionGenes.R
# Paul Aiyetan, MD
# August 04, 2015

# helper function(s) ---- #
findRegionGenes <-
 function(chr, loc.start, loc.end, Chr2MappedGenes, Chr2MappedGenesLocations){
    chrMappedGenes <- Chr2MappedGenes[[ chr ]]
    regionMappedGenes <- c()
    for(i in 1:length(chrMappedGenes)){
      # get gene start site
      g.start <- Chr2MappedGenesLocations[[ chr ]][[ chrMappedGenes[i] ]]$gene.start
      g.end <- Chr2MappedGenesLocations[[ chr ]][[ chrMappedGenes[i] ]]$gene.end
      # if gene start location falls within chromosomal region
      #     include in region mapped genes
      if( (g.start >= loc.start) & (g.start <= loc.end)) {
         regionMappedGenes <- c(regionMappedGenes, chrMappedGenes[i])
      }
    }
    return(regionMappedGenes)
 }
