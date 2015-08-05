# extractSegMeanExprsMatrix.R
# Paul Aiyetan
# August 04, 2015


extractSegMeanExprsMatrix
  function(cellLineGenesAssMaxSegMeansList){
    # get common genes across...
    cellLines <- names(cellLineGenesAssMaxSegMeansList)
    genes <- unique(unlist(lapply(cellLineGenesAssMaxSegMeansList,
                            function(x){
                              return(names(x))
                            })))
    mat <- matrix(nrow=length(genes), ncol=length(cellLines))
    colnames(mat) <- cellLines
    rownames(mat) <- genes
    for(i in 1:ncol(mat)){
      gene <- genes[i]
      for(j in 1:nrow(mat)){
         cellLineGenesAssMaxSegMeans <- cellLineGenesAssMaxSegMeansList[[j]]
         if(gene %in% names(cellLineGenesAssMaxSegMeans)){
            mat[i,j] <- cellLineGenesAssMaxSegMeans[[ gene ]]
         }else{
            mat[i,j] <- 0
         }
      }
    }
    return(t(mat))
  }
