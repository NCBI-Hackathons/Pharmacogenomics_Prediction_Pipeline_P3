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


