Overview
--------
A modular design helps organize data provenance.  This is accomplished using
a single "driver" workflow that calls many sub-workflows.

In Snakemake, this can be accomplished using one of two methods: subworkflows
or includes.  Both import other snakefiles into the main workflow. Subworkflows
allow different working directories to be set and allow the main workflow to
require a specific output file from the subworkflow's rules. Includes, on the
other hand, insert an entire snakefile verbatim into the main workflow.

Includes work better in this case because:

    - when writing a snakefile, we can use anything that was imported or
      defined in the main workflow. Here, this means that we don't have to keep
      reading the config file, keeping things clean and focused on the logic.

    - other snakefiles can be interdependent on each other simply by including
      one snakefile in another.

Much of the complexity of this project is preparing features for use in the
learning algorithms. This often involves several steps -- downloading,
filtering, combining, reformatting, and so on. The strategy is to have, for
each feature set, a separate snakefile. That snakefile is responsible for
creating one or several output files that will be used as features by the
learning algorithms.

This means that we can add a new feature set by writing a new snakefile and
telling the main workflow about it. This is accomplished using the
`config.yaml` file. It's probably easiest to look at an example:

Adding a new feature set
------------------------

Edit `config.yaml`. Choose a name for the feature set, and add an entry to the
`features` dictionary. The entry must have the filename of a Snakemake pipeline
and the name of an output file. If there are several output files, then use
a list of output files. Both paths are *relative to the runall.snakefile
directory*.

The current configuration uses "{prefix}" as a placeholder for the top-level
data directory. This makes it straightforward to swap the data directory across
all steps of all pipelines. For example, we can change the prefix to point
somewhere else for running small test datasets without changing anything else.

Next, write the snakefile referred to in the new `config.yaml` entry. This
snakefile is responsible for creating the output file or files referred to in
the new `config.yaml` entry.

Creating the snakefiles
-----------------------
`runall.snakefile` simply `include` s each child snakefile. This means that you
can use anything in the namespace of runall.snakefile -- including the config
obj and the helper functions. In fact, it would be a good idea to use
`config["features"][featureset_name]["output"]` as the output for the final
rule in the child snakefile, ensuring that `runall.snakefile` and the child
snakefile are expecting the same file to be created.


runall.snakefile automatically includes any snakefiles configured in
'config.yaml'.

In those child snakefiles, you can use anything in the namespace of
runall.snakefile -- including the config obj and the helper functions.

The child snakefiles are included verbatim, so beware rule name
collisions.

TODO: refactor all scripts to use input/output specified on commandline.
