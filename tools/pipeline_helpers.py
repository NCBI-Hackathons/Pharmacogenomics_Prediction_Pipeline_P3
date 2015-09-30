import numpy as np
import pandas as pd
import string


def sanitize(s):
    """
    Replace special characters with underscore
    """
    valid = "-_.()" + string.ascii_letters + string.digits
    return ''.join(i if i in valid else "_" for i in s)


def index_converter(df, label):
    """
    Sanitizes and appends "_" + `label` to each index entry.

    Returns the dataframe with altered index
    """
    def wrap(i):
        return sanitize('%s_%s' % (i, label))
    df.index = pd.Series(df.index).apply(wrap)
    return df


def pathway_scores_from_variants(variants_df, pathway_df, index_field):
    """
    Similar to `pathway_scores_from_zscores`, but with different subsetting
    logic that makes sense with integer variants per gene.
    """
    x = variants_df.join(pathway_df)
    dfs = []
    dfs.append(index_converter(pd.pivot_table(x, index=index_field, aggfunc=np.sum), 'sum_var'))
    dfs.append(index_converter(pd.pivot_table(x, index=index_field, aggfunc=np.mean), 'mean_var'))
    return pd.concat(dfs)


def pathway_scores_from_zscores(zscores_df, pathway_df, index_field):
    """
    Calculates a variety of pathway scores for each cell line, given a gene
    x cell line dataframe of zscores and a gene x annotation_type data frame of
    annotation labels.

    The annotation values will be sanitized to remove any special characters.

    Parameters
    ----------
    zscores_df : dataframe
        Index is Ensembl ID; columns are cell lines; values are zscores
    pathway_df : dataframe
        Index is Ensembl ID; columns are anything but must at least include
        `index_field`.
    index_field : str
        Column name to aggregate by, e.g., "GO" for gene ontology
    """

    # join dataframes on index
    x = zscores_df.join(pathway_df)

    dfs = []
    dfs.append(index_converter(pd.pivot_table(x[x>0],  index=index_field, aggfunc=np.sum),  'sum_pos'))
    dfs.append(index_converter(pd.pivot_table(x[x<0],  index=index_field, aggfunc=np.sum),  'sum_neg'))
    dfs.append(index_converter(pd.pivot_table(x,       index=index_field, aggfunc=np.sum),  'sum_all'))
    dfs.append(index_converter(pd.pivot_table(x[x>0],  index=index_field, aggfunc=np.mean), 'mean_pos'))
    dfs.append(index_converter(pd.pivot_table(x[x<0],  index=index_field, aggfunc=np.mean), 'mean_neg'))
    dfs.append(index_converter(pd.pivot_table(x,       index=index_field, aggfunc=np.mean), 'mean_all'))

    dfs.append(index_converter(pd.pivot_table(x[x>0],  index=index_field, aggfunc='count')
                             / pd.pivot_table(x[x>0],  index=index_field, aggfunc=len),  'frac_pos'))
    dfs.append(index_converter(pd.pivot_table(x[x<0],  index=index_field, aggfunc='count')
                             / pd.pivot_table(x[x<0],  index=index_field, aggfunc=len),  'frac_neg'))
    dfs.append(index_converter(pd.pivot_table(x[x!=0], index=index_field, aggfunc='count')
                             / pd.pivot_table(x[x!=0], index=index_field, aggfunc=len),  'frac_changed'))

    return pd.concat(dfs)


def stitch(filenames, sample_from_filename_func, index_col=0, data_col=1,
           **kwargs):
    """
    Given a set of filenames each corresponding to one sample and at least one
    data column, create a matrix containing all samples.

    For example, given many htseq-count output files containing gene ID and
    count, create a matrix indexed by gene and with a column for each sample.

    Parameters
    ----------
    filenames : list
        List of filenames to stitch together.

    sample_from_filename_func:
        Function that, when provided a filename, can figure out what the sample
        label should be. Easiest cases are those where the sample is contained
        in the filename, but this function could do things like access a lookup
        table or read the file itself to figure it out.

    index_col : int
        Which column of a single file should be considered the index

    data_col : int
        Which column of a single file should be considered the data.

    Additional keyword arguments are passed to pandas.read_table.
    """
    read_table_kwargs = dict(index_col=index_col)
    read_table_kwargs.update(**kwargs)
    dfs = []
    names = []
    for fn in filenames:
        dfs.append(pd.read_table(fn, **read_table_kwargs))
        names.append(sample_from_filename_func(fn))
    df = pd.concat(dfs, axis=1)
    df.columns = names
    return df


def remove_zero_variance(infile):
    """
    Remove rows with zero variance
    """
    d = pd.read_table(infile, index_col=0)
    return d[d.var(axis=1) == 0]


def remove_nfrac_variants(infile, nfrac=0.1):
    """
    Remove rows in which fewer than `nfrac` or greater than `1-nfrac` samples
    have a variant.
    """
    d = pd.read_table(infile, index_col=0)
    n = d.shape[1]
    n_nonzero = (d == 0).sum(axis=1).astype(float)
    too_low = (n_nonzero / n) <= nfrac
    too_high = (n_nonzero / n) >= (1 - nfrac)
    return d[~(too_low | too_high)]
