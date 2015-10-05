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

```bash
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

Once it's run, you can copy the results from the docker container to your
machine. Easiest way to do this is to leave the docker container running, then
open another terminal. Then:

```bash
# In another terminal . . .

# Get the ID of the running container. This is also part of the prompt in the running
# container, so you can just copy that if you want.
CONTAINER=$(docker ps | grep daler/p3 | awk '{print $1}')

# copy just the final output from the container
docker cp \
$CONTAINER:/data/Pharmacogenomics_Prediction_Pipeline_P3/example_data/runs/run_1/output \
final_output

tree final_output
#final_output/
#├── CX0030.log
#├── CX0030.RData
#├── CX0050.log
#├── CX0050.RData
#├── CX0051.log
#├── CX0051.RData
#├── CX0058.log
#├── CX0058.RData
#├── CX0065.log
#└── CX0065.RData
#
#0 directories, 10 files

```
