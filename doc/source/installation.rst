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

1. `Install docker <https://docs.docker.com/>`.

2. Clone the git repository::

    git clone https://github.com/NCBI-Hackathons/Pharmacogenomics_Prediction_Pipeline_P3.git P3

3. Pull the docker container::

    docker pull daler/p3

4. Change to the repository directory and start the container, exporting the repository directory to the running container::

   cd P3
   docker run -i -v `pwd`:/data -t daler/p3 /bin/bash

5. You should now be in the running docker container, in the `/data` directory,
   and with the contents of the repository in that directory. Run `snakemake`
   using the `prepare_example_data` rule to unzip the example data into the
   aptly-named `example_data` directory::

    snakemake prepare_example_data

6. Do a dry run to see what needs to be run::

    snakemake -n

7. Run the pipeline, using `-j` to specify the number of processors to use::

    snakemake -j8

8. Output will be in `example_data/runs/run_1/output/`. The final output is one
   `.RData` file for each sample. These files can be loaded into R, and
   contains a single object called `outSL` that contains the output of the
   SuperLearner run for that sample.

