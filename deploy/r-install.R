x <- read.table('r-cran-packages.txt', stringsAsFactors=FALSE)
install.packages(as.character(x[,1], dependencies=TRUE))

x <- read.table('r-bioconductor-packages.txt', stringsAsFactors=FALSE)
source('http://bioconductor.org/biocLite.R')
biocLite(as.character(x[,1]))

x <- read.table('r-github-packages.txt', stringsAsFactors=FALSE)
for (i in as.character(x[,1])){
    devtools::install_github(i)
}
