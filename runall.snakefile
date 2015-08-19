import yaml
from tools import pipeline_helpers
import os
import pandas
from textwrap import dedent

localrules: make_lookups


config = yaml.load(open('config.yaml'))
samples = [i.strip() for i in open(config['samples'])]
config['sample_list'] = samples
feature_targets = []
for name in config['features_to_use']:
    cfg = config['features'][name]
    workflow.include(cfg['snakefile'])
    outputs = cfg['output']
    if isinstance(outputs, dict):
        outputs = outputs.values()
    elif not isinstance(outputs, list):
        outputs = [outputs]
    for output in outputs:
        feature_targets.append(output.format(prefix=config['prefix']))

Rscript = config['Rscript']

lookup_targets = [i.format(prefix=config['prefix']) for i in [
    '{prefix}/metadata/ENSG2ENTREZID.tab',
    '{prefix}/metadata/ENSG2SYMBOL.tab',
    '{prefix}/metadata/genes.bed',
]]

rule all_features:
    input: feature_targets + lookup_targets


rule make_lookups:
    output: '{prefix}/metadata/ENSG2{map}.tab'
    shell:
        """
        {Rscript} tools/make_lookups.R {wildcards.map} {output}
        """

rule make_genes:
    output: '{prefix}/metadata/genes.bed'
    shell:
        """
        {Rscript} tools/make_gene_lookup.R {output}
        """
# vim: ft=python
