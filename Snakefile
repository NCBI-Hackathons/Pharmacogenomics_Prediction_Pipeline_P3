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

# Each run can define its own list of samples. Here we get the unique set of
# samples used across all runs so that we can generate the features for them.
samples = set()
for run_label, block in config['run_info'].items():
    samples_for_run = [i.strip() for i in open(block['sample_list'])]
    samples.update(samples_for_run)

config['sample_list'] = sorted(list(samples))

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

# Drug response files to be created. These are inferred from the
# `response_template` configured for each run.
drug_response_targets = set()
for run_label, block in config['run_info'].items():
    run_targets = expand(block['response_template'], prefix=config['prefix'], sample=samples)
    drug_response_targets.update(run_targets)
drug_response_targets = sorted(list(drug_response_targets))
drug_response_targets += expand(
    'runs/{run}/filtered/aggregated_response.tab',
    run=config['run_info'].keys())


# Filtered targets to be created for this run
filtered_targets = pipeline_helpers.filtered_targets_from_config('config.yaml')

filtered_targets += expand('runs/{run}/filtered/aggregated_features.tab', run=config['run_info'].keys())
# ----------------------------------------------------------------------------
# Create all output files. Since this is the first rule in the file, it will be
# the one run by default.
rule all:
    input:
        (feature_targets + lookup_targets + drug_response_targets
         + filtered_targets)


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


def get_input_from_filtered_output_wildcards(wildcards):
    """
    Based on the wildcards (which are expected to include `features_label` and
    `output_label`), figure out what the input file should be.

    Also fills in the prefix based on what config.yaml says.
    """
    outputs = config['features'][wildcards.features_label]['output']
    return outputs[wildcards.output_label].format(prefix=config['prefix'])


# ----------------------------------------------------------------------------
# This is one do-it-all rule to do the filtering. The logic of what filter to
# apply is left up to the function defined in the run_info of the config file.
rule do_filter:
    input: get_input_from_filtered_output_wildcards
    output: 'runs/{run}/filtered/{features_label}/{output_label}_filtered.tab'
    run:
        dotted_path = config['run_info'][wildcards.run]['feature_filter']
        function = pipeline_helpers.resolve_name(dotted_path)

        # NOTE: if exceptions are raised and they point to this line, check the
        # actual filter function code.
        d = function(infile=str(input[0]),
                 features_label=wildcards.features_label,
                 output_label=wildcards.output_label)
        d.to_csv(str(output[0]), sep='\t')


def all_filtered_output_from_run(wildcards):
    """
    Figures out all the filenames that need to be aggregated together.

    To be used as the input function for the `aggregate_filtered_features`
    rule.
    """
    filtered_files = []
    run = wildcards.run
    template = 'runs/{run}/filtered/{feature_label}/{output_label}_filtered.tab'
    for feature_label in config['features'].keys():
        for output_label in config['features'][feature_label]['output'].keys():
            filtered_files.append(template.format(**locals()))
    return filtered_files


rule aggregate_filtered_features:
    input: all_filtered_output_from_run
    output: 'runs/{run}/filtered/aggregated_features.tab'
    run:
        samples = [i.strip() for i in open(config['run_info'][wildcards.run]['sample_list'])]
        d = pipeline_helpers.aggregate_filtered_features(input)
        d[samples].to_csv(str(output[0]), sep='\t')
# vim: ft=python
