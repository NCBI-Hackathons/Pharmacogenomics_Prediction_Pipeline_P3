.. _filtering:

Filtering features and responses
================================
Depending on the learning algorithm chosen, it can be important to filter
features. Even when using random forests or penalized regression which are not
as sensitive to the input features, training will be more efficient after
removing uninformative features that have the same value across all samples
(i.e. features with zero variance).

It is expected that some experimentation will be needed to decide on the
optimal feature set. Therefore, the ``config.yaml`` file provides a mechanism
for specifying different **runs**. One run consists of a unique set of the
following operations:

    - filtering features
    - filtering response
    - a set of samples
    - a set of responses
    - learning parameters

For example, one run might use a basic zero variance filter across all
features, while a second run might try using a more stringent filter for
variant data. A third run could tweak which samples make it into the model.

In practice, feature filtering is performed by writing a custom Python
function. That function must accept 3 arguments: the input file for cleaned
features, the feature label, and the output label. It must return
a pandas.DataFrame object.  To illustrate, let's assume we have features for GO
terms variants in the following example ``config.yaml``::

    prefix: "/data/"
    features:
        go:
            snakefile: features/gene_ontology.snakefile
            output:
                zscores: "{prefix}/cleaned/go/go_zscores.csv"
                variants: "{prefix}/cleaned/go/go_variants.csv"

    run_info:
        run_1:
            feature_filter: filterfuncs.run1
            response_filter: filterfuncs.response1

Since we defined the `feature_filter` to be `filterfuncs.run1`, we need to
create a filter function in the file ``filterfuncs.py`` called `run1`:

.. code-block:: python

    def run1(infile, features_label, output_label):
        # read the input file
        d = pandas.read_table(infile, index_col=0)

        # The example config above only has one set of features, "go", so we
        # don't really have to check `features_label`...but this shows how it
        # would be done with more complex setups.
        #
        if features_label == 'go' and output_label == 'zscores':
            nonzero_var = d.var(axis=1) > 0
            d = d[nonzero_var]

        # only keep features where >10% of samples have variant data
        elif features_label == 'go' and output_label == 'variants':
            n = d.shape[1]
            n_nonzero = (d == 0).sum(axis=1).astype(float)
            too_low = (n_nonzero / n) <= nfrac
            too_high = (n_nonzero / n) >= (1 - nfrac)
            d = d[~(too_low | too_high)]

        # regardless of how we filtered, also get rid of rows with NA.
        return d.dropna()

Over the course of the workflow, this function will be called once for each
output file defined in each feature set. In the above config, there is one
feature set, ``go``, which has two expected output files,
`/data/cleaned/go/go_zscores.csv` and `/data/cleaned/go/go_variants.csv`. So
this function will be called twice during the filtering stage of the pipeline.
The pipeline will save the resulting files in a run-specific directory, named
after the feature and output label. So the pipeline will run the following:

.. code-block:: python


    run1("/data/cleaned/go/go_zscores.csv", "go", "zscores")
    # output saved to /data/runs/run_1/filtered/go/zscores_filtered.tab

    run1("/data/cleaned/go/go_variants.csv", "go", "variants")
    # output saved to /data/runs/run_1/filtered/go/variants_filtered.tab



Filtering samples and responses
-------------------------------
Filter which samples should be included in the model by editing the file
referred to in the `sample_list` config value in the `run_info` section.

Filter which responses (i.e. drugs) should be included in the model by editing
the file referred to in the `response_list` value in the `run_info` section.

In contrast, features are filtered using the custom functions referred to in
the `feature_filter` config value.

The reason for this is that the pipeline will ultimately be creating one model
for each drug. Due to the way Snakemake works, this means that we need to know
in advance which drugs will be used so that we can tell Snakemake which files
should be created.

In practice, deciding which drugs to include may involve some data analysis
outside of the pipeline to decide which drugs to add to the `response_list`.
For example, a drug may have no effect on any samples, in which case it is
uninteresting and can be removed. Some pre-processing of the data would be
required to figure this out, and the corresponding drug can be removed from the
`response_list`.

In contrast, we do not have output files created for each feature, so we don't
need to tell Snakemake about filenames. This allows us to perform the feature
filtering from within the pipeline. In addition, there are generally far more
features than responses, so using a hypothetical `feature_list` mechanism would
be awkward and difficult to maintain.
