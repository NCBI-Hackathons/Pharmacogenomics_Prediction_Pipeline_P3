Configuration
=============
Most configuration for P3 is performed by editing ``config.yaml``,
a text file using `YAML <https://en.wikipedia.org/wiki/YAML>`_ syntax.

See the :ref:`exampleconfig` below for a full example and to see how each part
relates. But first, we describe the parts of the config file and what they do.

Config sections
---------------

.. _config-prefix:

`prefix`
~~~~~~~~

Example:

.. code-block:: yaml

    prefix: example_data

This entry sets the directory `prefix` that can be used by any output filenames
(which will be described below). For example, in the :ref:`exampleconfig`, the
output filenames for the features start with the ``{prefix}`` placeholder.

It is convenient to set this to a directory containing a subset of the data
(but with the same filenames as real data) while developing the pipeline, and
then set it to the full data set once everything is working.

`features_to_use`
~~~~~~~~~~~~~~~~~

Example:

.. code-block:: yaml

    features_to_use: [cnv, exome_variants]

This entry selects the feature sets to use for a particular run. The items in the
list must correspond to feature sets defined in the :ref:`config-features`
section. Note that if one feature set depends on another, they must both be
included in this list.


`samples`
~~~~~~~~~
Example: 

.. code-block:: yaml

    samples: celllines.txt

This entry specifies a filename containing sample IDs to include in the
analysis. It is a text file with one sample name per line.


The final set of features will be subsetted to only include data from the
sample IDs specified in this file.

This file is parsed into a list of sample IDs within the `Snakefile`
workflow such that each child workflow can access the list of samples. This is
especially convenient when sample IDs are encoded in filenames and you want to
grab all files for all samples.


`Rscript`
~~~~~~~~~
Example:

.. code-block:: yaml

    Rscript: /usr/bin/Rscript

Sets the path to `Rscript`. Within Snakemake rules, an R file is then called
with the ``{Rscript}`` placeholder which will be filled in with the path
defined here:

.. code-block:: python

    rule example_r:
        input: '{prefix}/input_data.txt'
        output: '{prefix}/output_data.txt'
        shell:
            "{Rscript} myscript.R {input} {output}"

.. _config-features:

`features`
~~~~~~~~~~
Example:

.. code-block:: yaml

    features:
        cnv:
            snakefile: features/cnv.snakefile
            output:
                clusters: "{prefix}/filtered/cnv/cluster_scores.tab"
                max_gene: "{prefix}/filtered/cnv/cnv_gene_max_scores.tab"
                longest_gene: "{prefix}/filtered/cnv/cnv_gene_longest_overlap_scores.tab"

        exome_variants:
            snakefile: features/variants.snakefile
            output:
                by_gene: "{prefix}/filtered/exome_variants/exome_variants_by_gene.tab"


This is where new feature sets are defined. In this example, there are two
feature sets with the labels ``cnv`` and ``exome_variants``. Under each label
are two fields: ``snakefile`` and ``output``.

:snakefile:
    This field specifies the path, relative to the ``config.yaml`` file, to the
    Snakemake workflow that creates these features. This snakefile can do
    whatever it needs to do in order to create the output file[s].

:output:
    This field is a dictionary with at least one output file. The combination
    of feature label and output label must be unique (e.g., (`exome_variants`,
    `by_gene`) is unique).  These output files can use the ``{prefix}``
    placeholder which will be filled in with the :ref:`config-prefix` field. It
    is expected that these files will be created by the snakefile specified for
    this feature set. In this example, `featurex/cnv.snakefile` is expected to
    create the three output files listed and `features/variants.snakefile` is
    expected to create one output file.

.. note:: 

    Most of the effort in adding a new feature set is in writing the actual
    snakefile that does the work.  See :ref:`snakefiles` for more on this.

`run_info`
~~~~~~~~~~
Example:

.. code-block:: yaml

    run_info:
        run_1:
            feature_filter: "filterfuncs.run1"
            response_filter: "filterfuncs.aic1"

        run_2:
            feature_filter: "filterfuncs.run2"
            response_filter: "filterfuncs.aic1"

This is a dictionary that defines multiple runs. It is intended as the entry
point for configuring and tweaking filtering and learning parameters.  Each
entry (here, `run_1` and `run_2`) defines a unique set of feature filtering,
response filtering, and learning parameters. Each entry then has
the following keys:


:feature_filter:
    This is a dotted-notation specification of a Python filter function to use. See
    :ref:`filtering` for more details. In this example, we need a function
    called `run1` and another called `run2` in the `filterfuncs.py` Python
    module.


:response_filter:
    Similar to `feature_filter`, this is a function that will handle the
    filtering of response data.



.. _exampleconfig:

Example `config.yaml`
---------------------

This is the config file used to run the example data.

.. literalinclude:: ../../config.yaml
    :language: yaml
