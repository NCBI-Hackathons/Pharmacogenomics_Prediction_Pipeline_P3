#!/bin/bash
# Ideas from http://executableopinions.readthedocs.org/en/latest/labs/gh-pages/gh-pages.html
#
# By default, builds docs for the first remote listed under origin/fetch. If
# you are building on your own branch, then this uploads the docs to your
# branch on github. To override, pass the repo URI as the first argument to
# this script. You will need write permission on that repo.
#
set -e
set -x

if [ -z "$1" ]; then
    # use the first "fetch origin" repo listed
    REPO=$(git remote -v | grep fetch | awk '{print $2}' | head -n1)
else
    REPO=$1
fi


HERE=$(pwd)
MSG="Adding gh-pages docs for $(git log --abbrev-commit | head -n1)"
DOCSOURCE=$HERE/doc/build/html
TMPREPO=/tmp/doc

# make docs
(cd doc && make clean html)

# checkout a fresh copy of the remote's gh-pages branch to a temp location
rm -rf $TMPREPO
mkdir -p -m 0755 $TMPREPO
git clone $REPO $TMPREPO
cd $TMPREPO
git checkout gh-pages

# Now copy the freshly-made docs in the current repo over to the temp gh-pages
# branch.
cp -r $DOCSOURCE/* $TMPREPO

# ensure we have a .nojekyll file so github sees the "_"-prefixed folders
# created by sphinx when making the docs.
touch $TMPREPO/.nojekyll

# Commit and push. Now see <user>.github.io/<projectname> for the new docs.
git add -A
git commit -m "$MSG"
git push origin gh-pages
cd $HERE
