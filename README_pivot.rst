With respect to features, we have many cases where we download features as
a table with format gene X feature. However, for training, we need a table that
is cell line X feature. So for each cell line and feature, we need to calculate
a score across all genes for that feature in that cell line.

Take GO terms for example. Imagine genes 1, 2, 3, and 4 are annotated with GO
term "GO:001". To get a score for "GO:001" in cell line "A", we need some sort
of cell-line-specific data . . . like, say, RNA-seq. So imagine we also have
RNA-seq data where we've calculated zscores for each gene in each cell line.
Further imagine that the zscores in cell line "A" for genes 1, 2, 3, and 4 are
-3, -1, 0, and 5 respectively.


Possible scores for "GO:001" in cell line "A" might be:

    - sum of all zscores = 1
    - sum of downregulated = -4
    - sum of upregulated = 5
    - mean zscore = 0.25
    - fraction of all "GO:001"-annotated genes that are upregulated = 1/4
    - fraction of all "GO:001"-annotated genes that are downregulated = 2/4
    - fraction of all "GO:001"-annotated genes that are changed = 3/4
    - mean up-regulated zscore = 5
    - mean downregulated zscore = -2


The Python package "pandas" has some ridiculously fast pivot tables as long as
we restrict ourselves to NumPy and pandas.Series functions.

In the example below, file1 is a gene x feature tab-delimited file where one
column, "GO", contains the GO accession for each gene. file2 is gene x cell
line CSV file where values are zscores.

First, we load the files and join them on their index column. So now we have
columns for all cell lines as well as additional columns for features (one of
which is the GO accession column)::

    import pandas as pd
    x1 = pd.read_table(file1, delimiter='\t', index_col=0)
    x2 = pd.read_table(file2, delimiter=',', index_col=0)
    x = x1.join(x2)

Then we use pandas.pivot_table to do all the work for us. The important things
are which column to aggregate a score for ("GO") and how to do the aggregation
("aggfunc")::

    # sum of all zscores
    y0 = pd.pivot_table(x, index='GO', aggfunc=np.sum)

    # sum of all upregulated
    y1 = pd.pivot_table(x[x>0], index='GO', aggfunc=np.sum)

    # mean of all upregulated
    y2 = pd.pivot_table(x[x>0], index='GO', aggfunc=np.mean)

    # fraction upregulated
    # first get the count of upregulated. This calls the .count() method on
    # Series objects.
    y3 = pd.pivot_table(x[x>0], index='GO', aggfunc='count')

    # Then get how many there are total for each GO term.
    y4 = pd.pivot_table(x[x>0], index='GO', aggfunc=len)

    # Get the fraction
    y5 = y3 / y4


Note that at the end of the machine learning, we will want to be able to
inspect the resulting models for variable importance. In the above example, all
of the resulting `y*` dataframes have similar indexes so if we include more
than one of them in the final set of features, we won't know which is which.
The solution to this is to convert the indexes::

    def index_converter(df, label):
        return pd.Series(df.index).apply(lambda x: x.replace(':', '_') + label)

    y0.index = index_converter(y0, '_sum')
    y1.index = index_converter(y0, '_upsum')
    y2.index = index_converter(y0, '_upavg')
    y5.index = index_converter(y0, '_upfrac')

This is all taken care of in the `tools/pipeline_helpers.py` module in
`pathway_scores_from_zscores()`. Similarly, a version using variants as input
for scores rather than zscores can be made.
