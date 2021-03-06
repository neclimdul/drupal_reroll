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

if [ -e $PATCH ]
then
	cp $PATCH tmp.patch
else
	wget $PATCH -O tmp.patch
fi
# Get a branch to work in.
git branch -D reapply
git checkout -b reapply
sudo chmod a+w sites/default
git reset --hard $BRANCH

# Find the last commit the patch applies to.
while true
do
  git apply --index tmp.patch > /dev/null && break
  sudo chmod a+w sites/default
  git reset --hard HEAD^
done

git commit -m "Applying $PATCH"
tmp=$(git merge $BRANCH)
if [ $? -eq 0 ]; then
  echo 'Reapply successful.'
else
  echo 'Reapply failed.'
fi

rm tmp.patch
