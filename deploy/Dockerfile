# Pharmacogenomics Prediction Pipeline (P3) Docker image
#
# Prediction Pipeline (P3).
FROM bioconductor/release_core

MAINTAINER khughitt@umd.edu, dalerr@niddk.nih.gov

# Ubuntu packages
RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev \
    tree

# Add dependencies
ADD \
    r-bioconductor-packages.txt \
    r-cran-packages.txt \
    r-github-packages.txt \
    r-install.R \
    /tmp/

# Install R prerequisites
WORKDIR /tmp
RUN R -e "source('r-install.R')"

# Install Miniconda
RUN wget http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && bash Miniconda-latest-Linux-x86_64.sh -b -p /tmp/conda-build/anaconda
ENV PATH=/tmp/conda-build/anaconda/bin:$PATH

# Install non-R requirements via the bioconda channel
ADD \
    conda-requirements.txt \
    /tmp/
RUN conda install -y -c bioconda --file conda-requirements.txt

# Create directory for data
RUN mkdir /data
WORKDIR /data
