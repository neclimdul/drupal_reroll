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

PATCH="$1"
BRANCH="$2"

# Get a branch to work in.
git branch -D reapply
git checkout -b reapply
git reset --hard $BRANCH

# Find the last commit the patch applies to.
while : ; do
  git reset --hard HEAD^
  $(curl -s $PATCH | git apply --index - > /dev/null)
  if [ $? -eq 0 ]; then
    break
  fi
done

git commit -m "Applying $PATCH"
tmp=$(git merge $BRANCH)
if [ $? -eq 0 ]; then
  echo 'Reapply successful.'
else
  echo 'Reapply failed.'
fi