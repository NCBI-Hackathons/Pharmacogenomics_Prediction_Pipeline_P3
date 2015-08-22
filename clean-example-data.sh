#!/bin/bash

# Create a fresh copy of example_data
#
# Used for testing the pipeline starting from raw data.
#
# e.g.,
#
#
#   ./clean-example-data.sh
#   snakemake -pr -s runall.snakefile
#
# To do a full test.
#
#
if [ -e example_data ]; then
    rm -rf example_data
fi
mkdir -p example_data
(cd example_data && unzip ../sample_in_progress/raw.zip)
