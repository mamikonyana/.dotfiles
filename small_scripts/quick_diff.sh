#!/bin/zsh
#short-name: quickdiff

git checkout -b "quickdiff-$(date "+%Y-%m-%dT%H-%M-%S")"
git commit -a -m "$1"
arc diff --verbatim --allow-untracked --reviewers $2
