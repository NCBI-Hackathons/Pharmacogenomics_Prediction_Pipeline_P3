Molecular Matching in Myeloma (M<sup>3</sup>)
=============================================

```
 ____  _                                                                           _          
|  _ \| |__   __ _ _ __ _ __ ___   __ _  ___ ___   __ _  ___ _ __   ___  _ __ ___ (_) ___ ___ 
| |_) | '_ \ / _` | '__| '_ ` _ \ / _` |/ __/ _ \ / _` |/ _ \ '_ \ / _ \| '_ ` _ \| |/ __/ __|
|  __/| | | | (_| | |  | | | | | | (_| | (_| (_) | (_| |  __/ | | | (_) | | | | | | | (__\__ \
|_|   |_| |_|\__,_|_|  |_| |_| |_|\__,_|\___\___/ \__, |\___|_| |_|\___/|_| |_| |_|_|\___|___/
                                                  |___/                                       
 ____               _ _      _   _             
|  _ \ _ __ ___  __| (_) ___| |_(_) ___  _ __  
| |_) | '__/ _ \/ _` | |/ __| __| |/ _ \| '_ \ 
|  __/| | |  __/ (_| | | (__| |_| | (_) | | | |
|_|   |_|  \___|\__,_|_|\___|\__|_|\___/|_| |_|
                                               
 ____  _            _ _               ______ _______  
|  _ \(_)_ __   ___| (_)_ __   ___   / /  _ \___ /\ \ 
| |_) | | '_ \ / _ \ | | '_ \ / _ \ | || |_) ||_ \ | |
|  __/| | |_) |  __/ | | | | |  __/ | ||  __/___) || |
|_|   |_| .__/ \___|_|_|_| |_|\___| | ||_|  |____/ | |
        |_|                          \_\          /_/ 
```

Overview
--------

@TODO

TODO
----

- Update project name (change to "D3")
- Rename Github repo
- Move scripts from `tools` to `src` and normalize names, e.g.
    `datatype_function.R`
- Normalize data file names and extensions:
    - `csv` comma-separated
    - `tab` tab-delimited
- Normalize orientation of intermediate file matrices (e.g. always have cell
    lines for columns, genes for row, etc.)
- Create an example config and move all filenames to configuration file
    (exclude actual config from repo with .gitignore)

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

Input Data Files
----------------

**Copy Number file**

Standard multi-sample segmentation file (.seg)
- Format: Tab-deliminated

**RNA Seq Data**

Multi-sample matrix file of raw Ht-Seq Counts
- Format: Tab-deliminated
- Structure: 

```
Gene_ID	Sample1	Sample2	SampleN
ENSG001	10	40	58
ENSG002	497	91	1784
```

**Somatic Mutations Data**

Single sample matrix files
- Format: Tab-deliminated
- Column Headers
- NEED SIMPLE COLUMN HEADERS


Data Sources
------------

@TODO

Contact
-------

@TODO


