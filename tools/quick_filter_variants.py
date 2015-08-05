import pandas as pd
df = pd.read_table('/data/datasets/filtered/exome_variants/genes_per_cell_line.txt', index_col=0)
s = df.sum(axis=1)
df = df.ix[(s>4) & (s<25)]
df.to_csv('/data/datasets/filtered/exome_variants/genes_per_cell_line-count-filtered.txt', sep=',')

