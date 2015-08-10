#!/usr/bin/env python

# Ryan Dale 2015/8/4
import pandas as pd
import os
import mygene
import sys

mg = mygene.MyGeneInfo()

infile = sys.argv[1]
outfile = sys.argv[2]

gene_to_pathway = []
for line in open(infile):
    line = line.strip().split('\t')
    pathway = line[0]
    for entrez in line[2:]:
        gene_to_pathway.append((entrez, pathway))

df = pd.DataFrame(gene_to_pathway, columns=['entrez_id', 'pathway'])

lookup_file = '/data/datasets/metadata/entrez_to_ensembl'
if not os.path.exists(os.path.dirname(lookup_file)):
    os.makedirs(os.path.dirname(lookup_file))

if not os.path.exists(lookup_file):
    res = mg.querymany(
        list(df.entrez_id.unique()),
        scope='entrezgene',
        species='human',
        fields='ensembl.gene',
        as_dataframe=True
    )
    res.to_csv(lookup_file, sep='\t')
res = pd.read_table(lookup_file)

df.index = df['entrez_id'].astype(int)
res.index = res['query']
res.index.name = 'entrez_id'

joined = df.join(res).dropna(subset=['ensembl.gene'])
# There are some one-to-many mappings of entrez to ensembl. So repeat them.
with open('/data/datasets/raw/msig_db/c2.cp.v5.0.ensembl.tab', 'w') as fout:
    for _, row in joined.iterrows():
        if not isinstance(row['ensembl.gene'], list):
            ens = [row['ensembl.gene']]
        else:
            ens = row['ensembl.gene']
        for eg in ens:
            fout.write('\t'.join([eg, row['pathway']]) + '\n')


