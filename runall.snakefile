import yaml
from tools import pipeline_helpers
import os
import pandas
from textwrap import dedent

localrules: make_lookups

config = yaml.load(open('config.yaml'))
feature_targets = []
for name in config['features_to_use']:
    cfg = config['features'][name]
    workflow.include(cfg['snakefile'])
    outputs = cfg['output']
    if not isinstance(outputs, list):
        outputs = [outputs]
    for output in outputs:
        feature_targets.append(output.format(prefix=config['prefix']))

samples = [i.strip() for i in open(config['samples'])]

Rscript = config['Rscript']

def run_R(fn, log=None):
    if log is not None:
        log = " > {0} 2> {0}".format(log)
    else:
        log = ""
    shell("/usr/bin/Rscript {fn} {log}")

rule all_features:
    input: feature_targets


rule make_lookups:
    output:
        entrez='{prefix}/metadata/ENSG2ENTREZID.tab',
        symbol='{prefix}/metadata/ENSG2SYMBOL.tab',
    run:
        for map_to in ['ENTREZID', 'SYMBOL']:
            shell('{Rscript} tools/make_lookup.R {map}')

# vim: ft=python
