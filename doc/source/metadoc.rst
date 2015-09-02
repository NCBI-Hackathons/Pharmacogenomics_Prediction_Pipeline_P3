Documentation about the documentation
-------------------------------------

These docs are built using `Sphinx <http://sphinx-doc.org>`_ and served on
github. Here's how to rebuild and upload them.

.. note::

    All paths below are relative to the top-level dir of the repo

Run the pipeline on example data

--------------------------------
The documentation includes customized DAGs of the workflows. To generate these,
first the example pipeline must have been successfully run. Here's how to do
that on the biowulf cluster:

.. code-block:: bash

    ./clean-example-data.sh
    module load bedtools R  # on biowulf
    snakemake -npr -s runall.snakefile  # dry run
    snakemake -pr -s runall.snakefile  # run everything

If you have made any changes to the documentation, make sure you commit them
now::

    git status


.. note::

    The following commands assume your latest work was on the master branch.
    This is generally a good assumption because it means that the docs match
    the code in master. But merging from another branch might be useful if
    you're playing around with changes to the docs themselves.

Merge master with gh-pages branch
---------------------------------

Relative to the top-level dir of the repo:

.. code-block:: bash

    git checkout gh-pages
    git merge master
    cd doc
    make dags
    make clean html

In a browser, check the built docs at ``doc/build/html/index.html``. If
everything looks OK, you're ready to push to github::

    git status
    git commit -a -m 'rebuild docs'
    git push origin gh-pages

And finally, get back to the master branch::

    git checkout master

Now check the new docs (might need to force refresh) at
http://ncbi-hackathons.github.io/Pharmacogenomics_Prediction_Pipeline_P3/doc/build/html.
