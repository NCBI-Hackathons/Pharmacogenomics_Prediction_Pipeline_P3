#!/usr/bin/env python

"""
Convert msigdb Entrez accessions to Ensembl. Since there are some one-to-many
mappings of entrez to ensembl, we repeat those rows so one row corresponds to
one Ensembl ID.

MSIG requires a confirmation page, so its download cannot be well automated. So
here we expect the presence of the already-downloaded file.

This downloaded file has an awkward format: pathway name, url, followed by an
arbitrary number of Entrez IDs annotated for that pathway. This script uses the
MyGene.info service to lookup entrez to ensemble IDs, and then creates an
output file mapping Ensembl accession to pathway.
"""

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

# Use MyGene.info to get lookup
res = mg.querymany(
    list(df.entrez_id.unique()),
    scope='entrezgene',
    species='human',
    fields='ensembl.gene',
    as_dataframe=True
)

# Important to convert the incoming dataframe's index to int; otherwise it
# won't join with the MyGene.info results which are int.
df.index = df['entrez_id']
res.index.name = 'entrez_id'

joined = df.join(res).dropna(subset=['ensembl.gene'])

# There are some one-to-many mappings of entrez to ensembl. So repeat them.
with open(outfile, 'w') as fout:
    for _, row in joined.iterrows():
        if isinstance(row['ensembl.gene'], unicode):
            ens = [row['ensembl.gene']]
        else:
            ens = row['ensembl.gene']
        for eg in ens:
            fout.write('\t'.join([eg, row['pathway']]) + '\n')
