"""
Prepares different "flavors" of variants for use in combination with pathways/annotations
"""

import pandas
import glob
import os
import argparse
import numpy

ap = argparse.ArgumentParser()
ap.add_argument('sourcedir', help='Source dir containing *.vcf*.txt files')
ap.add_argument('--pattern', help='Pattern used to find files in `sourcedir`, default=%(default)s', default='*.vcf.filt_NS.txt')
ap.add_argument('lookup', help='Tab-delimited file containing ENSG to ENST mapping')
args = ap.parse_args()
fns = glob.glob(os.path.join(args.sourcedir, args.pattern))
lookup = pandas.read_table(args.lookup, header=0)
dfs = []
for fn in fns:
    df = pandas.read_table(fn)
    df['cellline'] = '_'.join(os.path.basename(fn).split('_')[:2])
    dfs.append(df)
dfs = pandas.concat(dfs)
dfs.index = numpy.arange(len(dfs))
dfs['ENSEMBLTRANS'] = dfs['EFF[*].TRID']
dfs = dfs.join(lookup, on='ENSEMBLTRANS', rsuffix='_')


# join lookup table
pandas.pivot_table(dfs, columns='cellline', index='EFF[*].TRID', aggfunc=len).dropna(how='all').fillna(0).head()
