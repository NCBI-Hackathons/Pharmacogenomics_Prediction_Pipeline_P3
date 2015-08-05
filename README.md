Molecular Matching in Myeloma (M<sup>3</sup>)
=============================================

Overview
--------

@TODO

Installation
------------

The M<sup>3</sup> pipeline uses a combination of
[Python](https://www.python.org/) and [R](https://www.r-project.org/).

Pipeline automation is handled using the
[Snakemake](https://bitbucket.org/johanneskoester/snakemake/wiki/Home) build
system, and can be easily parallelized to run across multiple CPUs.

**Requirements**

The `deploy` directory contains requirements files for Python, R, and Ubuntu. These requirements have been included in the Docker container (@TODO link here) The accompanying `Dockerfile` shows the setup to be performed (using the Bioconductor Docker container as a base), but
- Python (2.7+)
- R (3.2+)

Usage
-----

To run the M<sup>3</sup> pipeline, enter the root repo directory and run the
command:

TODO: CONFIGURATION RELATING TO EXPECTED DATA FILES

```sh
snakemake
```

This will start the build...

Data Sources
------------

@TODO

Contact
-------

@TODO


