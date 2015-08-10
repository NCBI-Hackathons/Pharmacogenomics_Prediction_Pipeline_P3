import yaml
from tools import pipeline_helpers
import os
import pandas
from textwrap import dedent

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

Rscript = config['Rscript']

def run_R(fn, log=None):
    if log is not None:
        log = " > {0} 2> {0}".format(log)
    else:
        log = ""
    shell("/usr/bin/Rscript {fn} {log}")

rule all_features:
    input: feature_targets

# vim: ft=python
