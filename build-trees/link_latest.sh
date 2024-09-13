#!/bin/bash
# Takes a list of dts files for the specified architecture and emits appropriate compiled dtb files for use in customised deviceTree setups.
#

dtc=/usr/bin/dtc
cdir=`pwd`
versions=`dpkg --list | grep linux-image-[0-9].* | cut -d" " -s -f 3 | sed s/^linux-image-// | sort -V`
current=`/usr/bin/uname -r`
revision=`echo $versions | tail -1`
out=./latest

echo -e "\nAvailable kernels:"
option=0
declare -a klist
for ver in $versions ; do
    option=$((option+1))
    klist[$option]=$ver
    echo -n "  [$option]  $ver"
    if [ $ver == $current ] ; then
        echo " - current running kernel"
    else
        echo
    fi
done

read -p "Which kernel to link? [$option]: " choice
if [ -z "$choice" ] ; then choice=$option ; fi

revision=${klist[$choice]}
if [ -z "$revision" ] ; then
    echo "No valid kernel selected, exiting."
    exit
fi

if [ -d "$revision" ]; then
    echo "Cleaning '$out' and creating new links to device tree binaries in '$revision'"
    mkdir -p $out
    rm -f $out/*.dtb
else
    echo "No builds for selected kernel version: $revision"
    echo "  Try running ./make_trees.sh to generate them"
    exit 1
fi

for file in `ls $revision/*.dtb`; do
    link=`echo "$file" | sed "s/$revision\/$revision-//g"`
    echo "  $out/$link --> $cdir/$file"
    ln -sf "$cdir/$file" "$out/$link"
done

# Test for link in /etc/flash-kernel/dtbs ?

echo
read -p "Run 'flash-kernel' to apply linked device tree (requires sudo)? [Y]: " choice
if [[ "$choice" == [Yy]* ]] || [ -z "$choice" ] ; then
    sudo flash-kernel
    echo -e "\nIf flash-kernel was successful and configured properly the new device tree will be used after reboot"
fi
echo
# fin
