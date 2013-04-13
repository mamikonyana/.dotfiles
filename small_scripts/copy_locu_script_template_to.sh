#!/bin/sh
#short-name: createscript

cp "`git rev-parse --show-toplevel`/website/scripts/TEMPLATE_SCRIPT.py" $1

# Rename the placeholders
sed -i "s+___SCRIPT_NAME___+$1+g" $1

# Start editing
$EDITOR $1
