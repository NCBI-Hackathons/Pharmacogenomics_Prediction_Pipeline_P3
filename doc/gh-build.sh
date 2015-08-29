#!/bin/bash
set -e

# Originally tried to automate things. But now just prints out what needs to be
# done in order to allow custom merging etc.
#
# The idea is to build the docs on the gh-pages branch by changing to that
# branch, merging whatever changes you committed in the branch from which you
# called this script, and prints out some reminders for what to do next . . .

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo
echo "# 1. Checkout gh-pages branch:"
echo
echo "    git checkout gh-pages"
echo
echo "# 2. Merge with the branch we just came from:"
echo
echo "    git merge ${CURRENT_BRANCH}"
echo
echo "# 3. Rebuild docs while on gh-pages branch:"
echo
echo "    make clean html"
echo
echo "# 4. Now commit changes and push:"
echo
echo "    git status"
echo "    git commit -a -m 'rebuild docs' "
echo "    git push origin gh-pages"
echo
echo "# 5. ...and change back to the branch you were working on:"
echo
echo "    git checkout ${CURRENT_BRANCH}"
echo
echo "# You are now here:"
echo
git branch
echo
