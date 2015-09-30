"""
This is the main workflow integrating many sub-workflows.
"""

import yaml
from tools import pipeline_helpers
import os
import pandas
from textwrap import dedent

localrules: make_lookups

# The workflow defined for each feature set defined in config.yaml is imported
# into this workflow. This modular approach avoids cluttering this main
# snakefile with lots of feature set-specific rules.
#
# Since the sub-workflows come in to the namespace of this file, they can use
# anything in this file. Things useful in sub-workflows might be:
#   - the imported pipeline_helpers module
#   - the `config` object
#   - the `samples` list
#   - the `Rscript` path.
config = yaml.load(open('config.yaml'))
samples = [i.strip() for i in open(config['samples'])]
config['sample_list'] = samples

# Output[s] for each feature set defined in the config will added to the
# feature_targets list.
feature_targets = []
for name in config['features_to_use']:
    cfg = config['features'][name]

    # Includes the defined snakefile into the current workflow.
    workflow.include(cfg['snakefile'])

    # Add outputs to feature_targets. Outputs can be a string, list, or dict.
    outputs = cfg['output']
    if isinstance(outputs, dict):
        outputs = outputs.values()
    elif not isinstance(outputs, list):
        outputs = [outputs]
    for output in outputs:
        feature_targets.append(output.format(prefix=config['prefix']))

# Whenever the placeholder string "{Rscript}" shows up in the body of a rule,
# this configured path will be filled in.
Rscript = config['Rscript']

# These are gene-related lookup files to be generated. Note that here `prefix`
# is filled in with the value provided in config.yaml.
lookup_targets = [i.format(prefix=config['prefix']) for i in [
    '{prefix}/metadata/ENSG2ENTREZID.tab',
    '{prefix}/metadata/ENSG2SYMBOL.tab',
    '{prefix}/metadata/genes.bed',
]]

# Drug response files to be created. Note prefix and
drug_response_targets = expand(
    '{prefix}/processed/drug_response/{sample}_{datatype}.tab', sample=samples,
    prefix=config['prefix'], datatype=['drugIds', 'drugResponse', 'drugDoses',
                                       'drugDrc'])

# ----------------------------------------------------------------------------
# Create all output files. Since this is the first rule in the file, it will be
# the one run by default.
rule all:
    input: feature_targets + lookup_targets + drug_response_targets


# ----------------------------------------------------------------------------
# A rule just for creating the feature output files
rule all_features:
    input: feature_targets + lookup_targets

# ----------------------------------------------------------------------------
# Make lookup tables from ENS gene IDs to other ids. Which ones to make depends
# on the filenames in `lookup_targets`.
rule make_lookups:
    output: '{prefix}/metadata/ENSG2{map}.tab'
    shell:
        """
        {Rscript} tools/make_lookups.R {wildcards.map} {output}
        """

# ----------------------------------------------------------------------------
# Make a gene lookup table, and get rid of leading "chr" on chrom names.
rule make_genes:
    output: '{prefix}/metadata/genes.bed'
    shell:
        """
        {Rscript} tools/make_gene_lookup.R {output}
        sed -i "s/^chr//g" {output}
        """

# ----------------------------------------------------------------------------
# For each configured sample, converts the NCATS-format input file into several
# processed files.
rule process_response:
    input: '{prefix}/raw/drug_response/s-tum-{sample}-x1-1.csv'
    output:
        drugIds_file='{prefix}/processed/drug_response/{sample}_drugIds.tab',
        drugResponse_file='{prefix}/processed/drug_response/{sample}_drugResponse.tab',
        drugDoses_file='{prefix}/processed/drug_response/{sample}_drugDoses.tab',
        drugDrc_file='{prefix}/processed/drug_response/{sample}_drugDrc.tab'
    params: uniqueID='SID'
    shell:
        """
        {Rscript} tools/drug_response_process.R {input} \
        {output.drugIds_file} {output.drugResponse_file} {output.drugDoses_file} \
        {output.drugDrc_file} {params.uniqueID}
        """

# ----------------------------------------------------------------------------
# Create a fresh copy of example_data
# Used for testing the pipeline starting from raw data.
rule prepare_example_data:
    shell:
        """
        if [ -e example_data ]; then
            rm -rf example_data
        fi
        mkdir -p example_data
        (cd example_data && unzip ../sample_in_progress/raw.zip)
        """

# vim: ft=python
