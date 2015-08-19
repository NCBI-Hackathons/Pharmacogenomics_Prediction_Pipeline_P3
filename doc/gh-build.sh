#!/bin/bash
set -e

# Builds the docs on the gh-pages branch by changing to that branch, merging
# whatever changes you committed in the branch from which you called this
# script, and prints out some reminders for what to do next . . .

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout gh-pages
git merge ${CURRENT_BRANCH}
make clean html

echo
echo "# Now commit changes and push:"
echo
echo "    git commit -a -m 'rebuild docs' "
echo "    git push origin gh-pages"
echo
echo "#...and change back to the branch you were working on:"
echo
echo "    git checkout ${CURRENT_BRANCH}"
echo
echo "# You are now here:"
echo
git branch
