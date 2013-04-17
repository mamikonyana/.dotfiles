#!/bin/zsh
#short-name: quickdiff

git checkout -b "$(echo $1 | sed 's/[^a-zA-Z]/_/g' | cut -c -20)-$(date '+%y%m%dT%H-%M-%S')"
git commit -a -m "$1"
arc diff --verbatim --allow-untracked --reviewers $2
