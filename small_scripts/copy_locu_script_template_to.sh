#!/bin/sh
#short-name: createscript

cp "`git rev-parse --show-toplevel`/website/scripts/TEMPLATE_SCRIPT.py" $1

# Rename the placeholders
sed -i "s+___SCRIPT_PATH___+$1+g" $1
sed -i "s+___USER___+`whoami`+g" $1
echo `whoami`

# Start editing
$EDITOR $1
