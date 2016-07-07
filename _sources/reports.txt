Reporting
=========
Reports are generated using RMarkdown. Each report has a relatively simple
driver script (see `tools/visualize_*.R`) that is called from a relevant
Snakefile rule, and that driver script renders an RMarkdown template file. The
output is an HTML file whose filename was specified in the snakefile rule. That
is::

    snakefile rule ->
      driver script _>
        RMarkdown template ->
          output HTML report

Or as a more specific example::

    features/normed_counts.snakefile: "rnaseq_visualization_normed" rule ->
      tools/visualize_rnaseq_data.R ->
        reports/templates/visualize_rnaseq_normed.Rmd ->
          {prefix}/reports/normalized_rnaseq.html


The job of the driver script is to:

- parse the arguments passed by the rule
- build a `params` object
- identify the output file
- specify the RMarkdown template file (typically hard-coded)
- pass them all to `rmarkdown::render`

Most of the actual reporting work is performed in the template RMarkdown file.
These live in the `reports/templates` directory. For better re-usability and to
reduce repeated code, RMarkdown templates can call child templates. For
example, `reports/templates/visualize_rnaseq_normed.Rmd` mostly consists of
rendering child templates. There is also a `reports/templates/R` directory from
which common code can be source from within an RMarkdown file.

Building a new report
---------------------
- write an RMarkdown file; decide what information it needs as input
- write a driver script to parse that information from a command-line call and
  put it into a `params` object
- add a rule to the relevant snakefile workflow that calls the driver script;
  specify your output file here as well
- add the output file to the final targets list
