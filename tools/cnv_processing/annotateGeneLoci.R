# annotateGeneLoci.R
# Paul Aiyetan,
# August 03, 2015

require(snowfall)
require(foreach)

ensembleMap <- read.table("./data/martquery_0804165124_755.txt",
                  sep="\t", stringsAsFactors=FALSE, header =TRUE)

seqAssayInfo <- read.table("./data/HMCL_All_CBS.seg",
                  header = TRUE, sep = "\t", stringsAsFactors=FALSE)
                  
seqAssayInfoList <-
  lapply(unique(seqAssayInfo$ID), function(x, y=seqAssayInfo){
    seqAssayInfoMiniTable <- y[y$ID==x, ]
    return(seqAssayInfoMiniTable)
  })
names(seqAssayInfoList) <- unique(seqAssayInfo$ID)
                  
# maps Chr - Genes
Chr2MappedGenes <-
      lapply(unique(ensembleMap$Chromosome.Name),function(x){
             mappedGenesSubTable <- ensembleMap[ensembleMap$Chromosome.Name== x, ]
             mappedGenes <- mappedGenesSubTable$Ensembl.Gene.ID
             return(mappedGenes)}
             )
names(Chr2MappedGenes) <- unique(ensembleMap$Chromosome.Name)
save(Chr2MappedGenes,file="./objs/Chr2MappedGenes.rda")
load(file="./objs/Chr2MappedGenes.rda")

# maps each gene to locations
Chr2MappedGenesLocations <- lapply(Chr2MappedGenes, function(x,eMap=ensembleMap){
                        lapply(x, function(y,eM=eMap){
                           gene.start <- eM[eM$Ensembl.Gene.ID==y,"Gene.Start..bp."]
                           gene.end <- eM[eM$Ensembl.Gene.ID==y,"Gene.End..bp."]
                           gene.length <- (gene.end - (gene.start - 1))
                           return( list(gene.start=gene.start,
                                      gene.end=gene.end,
                                        gene.length=gene.length ))
                        })
                     })
# name chromosomal gene list
for(i in 1:length(Chr2MappedGenesLocations)){
   names(Chr2MappedGenesLocations[[i]]) <- Chr2MappedGenes[[i]]
}
save(Chr2MappedGenesLocations,file="./objs/Chr2MappedGenesLocations.rda")
load(file="./objs/Chr2MappedGenesLocations.rda")


# map gene to Chromosome...

# Annotate seqAssayInfo for each file...
source("./codes/findRegionGenes.R")
cellLinesChrRegionBasedGeneList <-
  lapply(seqAssayInfoList, function(x){
            ChrRegionBasedGeneList <- list()
            for(i in 1:nrow(x)){
                #id <- seqAssayInfo[i, "ID"]
                chr <- x[i, "chrom"]
                loc.start <- x[i, "loc.start"]
                loc.end <- x[i, "loc.end"]
                region.genes <- findRegionGenes(chr, loc.start, loc.end,
                                            Chr2MappedGenes,
                                              Chr2MappedGenesLocations)
                #ChrRegionBasedGeneList[[ paste(id,chr,loc.start,loc.end,sep="_",collapse="_") ]] <- region.genes
                ChrRegionBasedGeneList[[ paste(chr,loc.start,loc.end,sep="_",collapse="_") ]] <- region.genes
            }
            return(ChrRegionBasedGeneList)}
        )

#save(ChrRegionBasedGeneList,file="./objs/ChrRegionBasedGeneList.rda")
#load(file="./objs/ChrRegionBasedGeneList.rda")
names(cellLinesChrRegionBasedGeneList) <- names(seqAssayInfoList)
save(cellLinesChrRegionBasedGeneList,file="./objs/cellLinesChrRegionBasedGeneList.rda")
load(file="./objs/cellLinesChrRegionBasedGeneList.rda")

# derive each cell line gene associated seg.mean (from the record with the highest num.mark value...
# derive each cell line gene associated seg.mean (s)
cellLineGenesAssSegMeansList <- list()
#for(i in length(cellLinesChrRegionBasedGeneList)){

# using the foreach construct for parellelizing....
 
cellLineGenesAssSegMeansList <- 
    foreach (i = 1:length(cellLinesChrRegionBasedGeneList), .inorder=TRUE) %dopar% {
        cellLineChrRegionGeneList <- cellLinesChrRegionBasedGeneList[[ i ]]
        cellLineSeqAssayInfoTable <- seqAssayInfoList[[ i ]]
        #cellLineAssGenes <- unique(unlist(cellLineChrRegionGeneList))
        cellLineGenesAssSegMeans <- list()
        for(j in 1:length(cellLineChrRegionGeneList)){
            chr.region <- names(cellLineChrRegionGeneList)[j]
            chr.region.genes <- cellLineChrRegionGeneList[[j]]

            for(k in 1:length(chr.region.genes)){
                #if(!names(cellLineGenesAssSegMeans)
                chr.region.gene <- chr.region.genes[k]
                if((chr.region.gene %in% names(cellLineGenesAssSegMeans)) == FALSE) {
                    cellLineGenesAssSegMeans[[chr.region.gene]] <- list()
                    # get chromosome, region.start (loc.start), region.end (loc.end)
                    chr.region.split.products <- unlist(strsplit(chr.region,"_"))
                    chr <- as.numeric(chr.region.split.products[1])
                    loc.start <- as.numeric(chr.region.split.products[2] )
                    loc.end <- as.numeric(chr.region.split.products[3])
                    
                    num.mark <- cellLineSeqAssayInfoTable[((cellLineSeqAssayInfoTable$chrom == chr) &
                                                          (cellLineSeqAssayInfoTable$loc.start == loc.start) &
                                                          (cellLineSeqAssayInfoTable$loc.end == loc.end)), "num.mark"]
                    seg.mean <- cellLineSeqAssayInfoTable[((cellLineSeqAssayInfoTable$chrom == chr) &
                                                          (cellLineSeqAssayInfoTable$loc.start == loc.start) &
                                                          (cellLineSeqAssayInfoTable$loc.end == loc.end) &
                                                          (cellLineSeqAssayInfoTable$num.mark == max(num.mark))), "seg.mean"]
                    if(!is.null(num.mark) & !is.null(seg.mean)){
                      cellLineGenesAssSegMeans[[chr.region.gene]][[ as.character(max(num.mark)) ]] <- max(seg.mean)
                    }
                } else {
                    # get chromosome, region.start (loc.start), region.end (loc.end)
                    chr.region.split.products <- unlist(strsplit(chr.region,"_"))
                    chr <- chr.region.split.products[1]
                    loc.start <- chr.region.split.products[2]
                    loc.end <- chr.region.split.products[3]

                    num.mark <- cellLineSeqAssayInfoTable[((cellLineSeqAssayInfoTable$chrom == chr) &
                                                          (cellLineSeqAssayInfoTable$loc.start == loc.start) &
                                                          (cellLineSeqAssayInfoTable$loc.end == loc.end)), "num.mark"]
                    seg.mean <- cellLineSeqAssayInfoTable[((cellLineSeqAssayInfoTable$chrom == chr) &
                                                          (cellLineSeqAssayInfoTable$loc.start == loc.start) &
                                                          (cellLineSeqAssayInfoTable$loc.end == loc.end) &
                                                          (cellLineSeqAssayInfoTable$num.mark == max(num.mark))), "seg.mean"]
                    if(!is.null(num.mark) & !is.null(seg.mean)){
                      cellLineGenesAssSegMeans[[chr.region.gene]][[ as.character(max(num.mark)) ]] <- max(seg.mean)
                    }
                }

            }
        }
        #cellLineGenesAssSegMeansList[[ i ]] <- cellLineGenesAssSegMeans
        cellLineGenesAssSegMeans
    }
names(cellLineGenesAssSegMeansList) <- names(cellLinesChrRegionBasedGeneList)
save(cellLineGenesAssSegMeansList, file="./objs/cellLineGenesAssSegMeansList.rda")
load(file="./objs/cellLineGenesAssSegMeansList.rda")

#  from the record with the highest num.mark value...
cellLineGenesAssMaxSegMeansList <- list()
#for(i in 1:length(cellLineGenesAssSegMeansList)){
cellLineGenesAssMaxSegMeansList <-
  foreach(i = 1:length(cellLineGenesAssSegMeansList), .inorder =TRUE) %dopar% {
      cellLineGenesAssSegMeans <- cellLineGenesAssSegMeansList[[i]]
      cellLineGenes <- names(cellLineGenesAssSegMeans)
      max.num.mark.seg.means <-
            lapply(cellLineGenes,function(x){
                   num.mark.values <- names(cellLineGenesAssSegMeans[[x]])
                   max.num.mark.value <- max(as.numeric(num.mark.values))
                   max.num.mark.seg.mean <- cellLineGenesAssSegMeans[[x]][[ as.character(max.num.mark.value) ]]
                   return(max.num.mark.seg.mean)})
    
      names(max.num.mark.seg.means) <- cellLineGenes
      #cellLineGenesAssMaxSegMeansList[[ i ]] <- max.num.mark.seg.means
      max.num.mark.seg.means
  }

names(cellLineGenesAssMaxSegMeansList) <- names(cellLineGenesAssSegMeansList)
save(cellLineGenesAssMaxSegMeansList, file="./objs/cellLineGenesAssMaxSegMeansList.rda")
load(file="./objs/cellLineGenesAssMaxSegMeansList.rda")

source("./codes/extractSegMeanExprsMatrix.R")
cellLinesGeneCNVMeanMatrix <- extractSegMeanExprsMatrix(cellLineGenesAssMaxSegMeansList)
save(cellLinesGeneCNVMeanMatrix, file ="./objs/cellLinesGeneCNVMeanMatrix.rda")
load(file ="./objs/cellLinesGeneCNVMeanMatrix.rda")

write.table(cellLinesGeneCNVMeanMatrix, file="./text/cellLinesGeneCNVMeanMatrix.tab", 
            sep="\t", quote = FALSE, row.names = TRUE)



