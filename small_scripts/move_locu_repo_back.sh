#!/bin/sh
#short-name: mvback
#interactive-shell: .

repo=`git rev-parse --show-toplevel`
rm $repo/website/settings_environment.py* 2>/dev/null 1>/dev/null
num=1
while [ -d $repo/../clean_$num ]
do
    num="$(( $num + 1 ))"
done
cd $repo/..
mv $repo $repo/../clean_$num
