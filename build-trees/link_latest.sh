#!/bin/bash
# Takes a list of dts files for the specified architecture and emits appropriate compiled dtb files for use in customised deviceTree setups.
#

dtc=/usr/bin/dtc
revision=`/usr/bin/uname -r`
current=`pwd`
out=./latest

if [ -d "$revision" ]; then
    echo "Linking $out to device trees in $revision"
else
    echo "No builds for current kernel version: $revision"
    echo "Try running ./make_trees.sh to generate it."
    exit 1
fi

mkdir -p $out

for file in `ls $revision/*.dtb`; do
    link=`echo "$file" | sed "s/$revision\/$revision-//g"`
    echo "  $out/$link --> $current/$file"
    ln -s "$current/$file" "$out/$link"
done
