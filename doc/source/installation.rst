Installation
============

P3 uses a combination of
`Python <https://www.python.org/>`_ and `R <https://www.r-project.org/>`_.

Pipeline automation is handled using the `Snakemake
<https://bitbucket.org/johanneskoester/snakemake/wiki/Home>`_ build system, and
can be easily parallelized to run across multiple CPUs.

**Requirements**

The `deploy/` directory contains requirements files for Python, R, and Ubuntu.
These requirements have been included in the Docker container. To run the
example in an isolated environment:

- Install `docker <https://docs.docker.com/>`_.

- Pull the docker container::

    docker pull daler/p3


- Run the docker container::

   docker run -i -t daler/p3 /bin/bash


- You should now be in the running docker container, in the `/data` directory,
  From inside the container, clone the git repository::

    git clone https://github.com/NCBI-Hackathons/Pharmacogenomics_Prediction_Pipeline_P3.git


- Change to the source code directory::

   cd Pharmacogenomics_Prediction_Pipeline_P3


- Run `snakemake` using the `prepare_example_data` rule to unzip the example
  data into the aptly-named `example_data` directory::

    snakemake prepare_example_data


Do a dry run to see what needs to be run::

    snakemake -n


Run the pipeline, using `-j` to specify the number of processors to use::

    snakemake -j8


Output will be in `example_data/runs/run_1/output/`. The final output
consists of one `.RData` file for each configured sample. Each file can be
loaded into R, and contains a single object called `outSL` that contains the
output of the SuperLearner run for that sample.

