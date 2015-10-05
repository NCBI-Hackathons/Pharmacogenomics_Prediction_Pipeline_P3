Pharmacogenomics Predicting Pipeline (P<sup>3</sup>)
====================================================

See http://ncbi-hackathons.github.io/Pharmacogenomics_Prediction_Pipeline_P3
for detailed documentation.

Overview
--------

The P<sup>3</sup> pipeline aims to predict drug sensitivity utilizing
second-generation sequencing data, biological annotation (gene ontology,
pathways, etc.), and *in vitro* high-throughput drug screening data.

![data flow diagram](https://raw.githubusercontent.com/DCGenomics/Pharmacogenomics_Prediction_Pipeline_P3/master/doc/architecture_20150804.png)

Quick start
-----------
The following steps perform an isolated test on example data, which should take
a few minutes to run on a laptop. It is assumed that
[Docker](https://www.docker.com/) is installed:

```
# Get the docker container (~1GB download)
docker pull daler/p3

# Run the docker container interactively. This starts us in the /data directory
# running the bash shell.
docker run -i -t daler/p3 /bin/bash

# Once in the container, get the P3 source code:
git clone https://github.com/NCBI-Hackathons/Pharmacogenomics_Prediction_Pipeline_P3.git

# Change to the source code dir
cd Pharmacogenomics_Prediction_Pipeline_P3

# Prepare example data
snakemake prepare_example_data

# Do a dry run to see what needs to be done
snakemake -n

# Run the pipeline, using 8 processors (adjust -j as necessary)
snakemake -j8
```


