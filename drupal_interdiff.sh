#!/bin/bash
#
# Description
#
# Many patches don't apply but can easily be reapplied by using git's very
# powerful merge tools. This script finds the last commit that the patch
# applied to, makes a temporary commit and then tries to merge against the
# given branch.
#
# Usage:
#
# 1) Checkout the branch you want to reapply the patch to.
# 2) run reapply.sh https://www.drupal.org/files/issues/foobar.patch origin/8.x
# 3) git diff origin/8.x > new.patch
#

PATCH1="$1"
PATCH2="$2"
BRANCH="$3"


if [ -e $PATCH1 ]
then
  cp $PATCH1 tmp1.patch
else
  wget $PATCH1 -O tmp1.patch
fi
if [ -e $PATCH2 ]
then
  cp $PATCH2 tmp2.patch
else
  wget $PATCH2 -O tmp2.patch
fi

# Get a branch to work in.
git branch -D patch1
git checkout -b patch1
git reset --hard $BRANCH
git apply --index tmp1.patch
git commit -m "Applying $PATCH1"

git branch -D patch2
git checkout -b patch2
git reset --hard $BRANCH
git apply --index tmp2.patch
git commit -m "Applying $PATCH2"

git diff patch1..patch2
