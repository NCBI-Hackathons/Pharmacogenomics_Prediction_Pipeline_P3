# vim: ft=python
import yaml
config = yaml.load(open('config.yaml'))
feature_targets = []
for name, cfg in config['features'].items():
    workflow.include(cfg['snakefile'])
    feature_targets.append(cfg['output'])

def run_R(fn, log=None):
    if log is not None:
        log = " > {0} 2> {0}".format(log)
    else:
        log = ""
    shell("/usr/bin/Rscript {fn} {log}")

rule all_features:
    input: feature_targets
