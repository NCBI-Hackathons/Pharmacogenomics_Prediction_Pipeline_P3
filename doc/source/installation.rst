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

You can copy the results from the docker container to your machine. Easiest way
to do this is to leave the docker container running, then open another
terminal. Then:


.. code-block:: bash

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

