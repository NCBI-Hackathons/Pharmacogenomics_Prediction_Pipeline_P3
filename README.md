Pharmacogenomics Predicting Pipeline (P<sup>3</sup>)
====================================================


See http://dcgenomics.github.io/Pharmacogenomics_Prediction_Pipeline_P3/doc/build/html for detailed documentation.



Overview
--------

The P<sup>3</sup> pipeline aims to predict drug sensitivity utilizing second-generation
sequencing data and biological annotation (gene ontology, pathways, etc.), in
vitro high-throughput drug screening data.

![data flow diagram](https://raw.githubusercontent.com/DCGenomics/Pharmacogenomics_Prediction_Pipeline_P3/master/doc/architecture_20150804.png)

Installation
------------

The P<sup>3</sup> pipeline uses a combination of
[Python](https://www.python.org/) and [R](https://www.r-project.org/).

Pipeline automation is handled using the
[Snakemake](https://bitbucket.org/johanneskoester/snakemake/wiki/Home) build
system, and can be easily parallelized to run across multiple CPUs.

**Requirements**

The `deploy/` directory contains requirements files for Python, R, and Ubuntu.
These requirements have been included in the Docker container (@TODO link here)
The accompanying `Dockerfile` shows the setup to be performed (using the
Bioconductor Docker container as a base) and the container will be eventually
provided on docker hub.

Usage
-----

To run the P<sup>3</sup> pipeline, enter the root repo directory and run the
command:

@TODO: CONFIGURATION RELATING TO EXPECTED DATA FILES

```sh
snakemake
```

This will start the build...

Input Data Files
----------------

@TODO: Clean up and combine text below...

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
- Column Headers (Proccessed Column is 19, header is required but specific header values are not required)) 
```
#CHROM	POS	ID	REF	ALT	1000G	COSMIC	DB	NHLBI	EFF[*].EFFECT	EFF[*].IMPACT	EFF[*].FUNCLASS	EFF[*].CODON	EFF[*].AA	EFF[*].AA_LEN	EFF[*].GENE	EFF[*].BIOTYPE	EFF[*].CODING	EFF[*].TRID	EFF[*].RANK	GEN[0].AD[0]	GEN[0].AD[1]	GEN[0].DP
```
- NEED SIMPLE COLUMN HEADERS


**Biological samples**

A large panel of cancer cell lines from the same tumor type.
 
**NGS data:**

QC and raw data should be processed outside the pipeline.

- RNAseq data: read counts (HTseq), differential gene expression compared to
    median expression in the dataset;
- DNAseq data: variant calls (GATK HaplotypeCaller)
- ArrayCGH (copy number variation)
 
**Drug response data**

@TODO: Remove the specifics of this section and save for dataset-specific
paper/analysis?

Cell lines were treated in 1,536-well plates and drug response data is
calculated based on cell viability readouts at 48 hours of drug exposure
(CellTiter Glo was used). The data were normalized using on plate positive and
negative controls using the formula:  100 * ( C - N ) / ( N - I ) + 100,  where
C is the response from the sample well, N is trimmed median of the negative
control wells and I is the trimmed median of the positive control wells.
Multiple compounds were tested and individual dose response curves (DRC) were
estimated using the four parameter nonlinear logistic regression model. The
estimated IC50 (called AC50 here) and additional metrics were added as the drug
sensitivity indicators, i.e. a numerical metric for the shape of the drug
response curve (class curve), the maximal response, and area under the curve
(the DRC fit and trapezoidal method based).
 
**Biological annotation**

Additional features for each cell line were defined using publically available
pathway annotation tools (i.e. GO Ontology, MSigDB, ConsensusPathDB, snpeff
annotation).

Data Sources
------------

@TODO

Contact
-------

@TODO


