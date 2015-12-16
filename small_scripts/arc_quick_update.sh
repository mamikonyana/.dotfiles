#!/bin/zsh
#short-name: arcupdate

git commit -a -m "$1"
arc diff --allow-untracked -m "$1"
