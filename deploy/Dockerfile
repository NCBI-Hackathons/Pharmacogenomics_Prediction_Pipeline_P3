#
# Pharmacogenomics Prediction Pipeline (P3) Docker image
# 2015/08/05
#
# This docker image provides a pre-configured container including all of
# the software and data needed to reproduce the results of the Pharmacogenomics
# Prediction Pipeline (P3).
#
# For more information, see the M3 github page at:
# https://github.com/DCGenomics/multiple_myeloma_rnaseq_drug_response_hackathon_v002/
#
FROM bioconductor/release_core

MAINTAINER khughitt@umd.edu

# Ubuntu packages
RUN apt-get update && \
    apt-get install -y \ 
    libcurl4-openssl-dev \
    libxml2-dev \
    tree 

# Python requirements
RUN pip install mygene

# Install R CRAN packages
ADD r-cran-packages.txt /tmp/

RUN for x in $(cat /tmp/r-cran-packages.txt); do \
    echo "Installing $x..."; \
    R -e "install.packages('$x');"; \
    done

# Install R Github packages
ADD r-github-packages.txt /tmp/

RUN for x in $(cat /tmp/r-github-packages.txt /tmp/); do \
    echo "Installing $x..."; \
    R -e "devtools::install_github('$x');"; \
    done

# Install R Bioconductor packages
RUN R -e "source('http://bioconductor.org/biocLite.R');"\
         "biocLite(c('preprocessCore', 'sva', 'genefilter', 'Homo.sapiens'), suppressUpdates=TRUE);"

# Create directory for data
RUN mkdir /data

# Clone P3 repo
RUN git clone https://github.com/DCGenomics/multiple_myeloma_rnaseq_drug_response_hackathon_v002
