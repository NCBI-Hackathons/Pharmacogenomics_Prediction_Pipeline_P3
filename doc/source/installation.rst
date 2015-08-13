Installation
============

P3 uses a combination of
`Python <https://www.python.org/>`_ and `R <https://www.r-project.org/>`_.

Pipeline automation is handled using the `Snakemake
<https://bitbucket.org/johanneskoester/snakemake/wiki/Home>`_ build system, and
can be easily parallelized to run across multiple CPUs.

**Requirements**

The `deploy/` directory contains requirements files for Python, R, and Ubuntu.
These requirements have been included in the Docker container (@TODO link here)
The accompanying `Dockerfile` shows the setup to be performed (using the
Bioconductor Docker container as a base) and the container will be eventually
provided on docker hub.
