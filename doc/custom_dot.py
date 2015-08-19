#!/usr/bin/env python
"""
This script is used to create color-coded sub-DAGs for the documentation.  It
is intended to be run from the "doc" directory, and can be triggered by running
the Makefile target "dags".

The "runall.snakefile" is run with each set of targets defined by the
config.yaml file to create a DAG just for that feature snakefile.

Each rule can therefore show up in multiple DAGs. The `color_lookup` dict
manages what the colors should be.

After the dot-format DAG is created, we do some post-processing to fix colors,
change the shape, etc. Then it's saved to the source/images dir as PDF and PNG.
"""

import pydot
from collections import defaultdict
import yaml
import os
from matplotlib import colors


def color(s):
    """
    Convert hex color to space-separated RGB in the range [0-1], as needed by
    the `dot` graph layout program.
    """
    rgb = colors.ColorConverter().to_rgb(s)
    return '"{0} {1} {2}"'.format(*rgb)


# Keys are rule names, colors are anything matplotlib can support (usually hex)
color_lookup = {
    'make_lookups': '#6666ff',
    'transcript_variant_matrix': '#0066cc',
    'transcript_variant_matrix_to_gene_variant_matrix': '#0066cc',
    'rnaseq_counts_matrix': "#753b00",
    'rnaseq_data_prep': "#753b00",
    'compute_zscores': '#cc6600',
    'seg_to_bed': '#4c9900',
    'multi_intersect': '#4c9900',
    'create_cluster_scores': '#4c9900',
    'cluster_matrix': '#4c9900',
    'create_gene_scores': '#4c9900',
    'gene_max_scores_matrix': '#4c9900',
    'gene_longest_overlap_scores_matrix': '#4c9900',
}


# This script lives in docs/, so we need to go up one to find the config.
config = yaml.load(open('../config.yaml'))
prefix = config['prefix']

# We'll be iterating through sub-workflows defined in the config, so add the
# main runall.snakefile as well. The target is the "all_features" rule -- this
# gets us the DAG for the entire combined workflow.
config['features']['all'] = dict(
    snakefile='runall.snakefile', targets='all_features')

for k, v in config['features'].items():
    snakefile = v['snakefile']

    # The value of output in config.yaml can be a string or dict; convert
    # either into a list we can work with
    targets = v.get('output', '')
    if isinstance(targets, dict):
        targets = targets.values()
    else:
        targets = [targets]

    # Fill in the "prefix" from config.yaml
    targets = [i.format(prefix=prefix) for i in targets]

    # Note we're doing a "cd .." in the subshell to make sure the snakefile
    # runs correctly.
    cmd = [
        'cd .. &&', 'snakemake',
        '--rulegraph',
        '-s', 'runall.snakefile']
    cmd.extend(targets)

    # destination is relative to `..` when within the subshell...
    cmd.append('> doc/source/images/%s.dot' % k)
    print ' '.join(cmd)
    os.system(' '.join(cmd))

    # ...but after it's created, we read it from relative to this script.
    d = pydot.dot_parser.parse_dot_data(
        open('source/images/%s.dot' % k).read())

    # Modify attributes
    for key, val in d.obj_dict['nodes'].items():
        try:
            label = val[0]['attributes']['label']
            label = label.replace('"', '')
            if label in color_lookup:
                val[0]['attributes']['color'] = color_lookup[label]
            else:
                val[0]['attributes']['color'] = color("#888888")
            del val[0]['attributes']['style']
        except KeyError:
            continue

    # Gets rid of "rounded" style
    del d.obj_dict['nodes']['node'][0]['attributes']['style']

    # Optionally lay out the graph from left-to-right
    # d.obj_dict['attributes']['rankdir'] = '"LR"'

    d.write_pdf('source/images/%s_dag.pdf' % k)
    d.write_png('source/images/%s_dag.png' % k)
