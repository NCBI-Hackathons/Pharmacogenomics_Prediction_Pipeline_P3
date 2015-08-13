import pandas
import numpy
samples = [i.strip() for i in open(config['samples'])]


rule combine_samples:
    input: expand('{{prefix}}/raw/exome_variants/{sample}_exome_variants.txt', sample=samples)
    output: '{prefix}/filtered/exome_variants/exome_variants_by_transcript.tab'
    run:
        dfs = []
        for fn in input:
            df = pandas.read_table(fn)
            df['sample'] = '_'.join(os.path.basename(fn).split('_')[:2])
            dfs.append(df)
        dfs = pandas.concat(dfs)
        dfs.index = numpy.arange(len(dfs))
        results = pandas.pivot_table(
            dfs[['EFF[*].TRID', 'sample']],
            columns='sample',
            index='EFF[*].TRID',
            aggfunc=len)\
                .dropna(how='all')\
                .fillna(0)
        results.to_csv(output[0], sep='\t')


rule transcript_to_gene:
    input:
        variants_table='{prefix}/filtered/exome_variants/exome_variants_by_transcript.tab',
        lookup_table='{prefix}/metadata/ENSG2ENSEMBLTRANS.tab'
    output: '{prefix}/filtered/exome_variants/exome_variants_by_gene.tab'
    run:
        lookup = pandas.read_table(str(input.lookup_table), index_col='ENSEMBLTRANS')
        variants = pandas.read_table(str(input.variants_table), index_col='EFF[*].TRID')
        x = variants.join(lookup).dropna(subset=['ENSEMBL'])
        results = x.groupby('ENSEMBL').agg(numpy.sum)
        results.to_csv(output[0], sep='\t')


# vim: ft=python
