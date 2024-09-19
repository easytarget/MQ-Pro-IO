#!/bin/bash
# Allows the user to choose a kernel version and copies .dtb files to /etc/flash-kernel
# - defaults to current highest available kernel version
#

cdir=`pwd`
versions=`dpkg --list | grep linux-image-[0-9].* | cut -d" " -s -f 3 | sed s/^linux-image-// | sort -V`
current=`/usr/bin/uname -r`
out=/etc/flash-kernel/dtbs

echo -e "\nAvailable kernels:"
option=0
declare -a klist
for ver in $versions ; do
    option=$((option+1))
    klist[$option]=$ver
    echo -n "  [$option]  $ver"
    if [ $ver == $current ] ; then
        echo " - currently running kernel"
    else
        echo
    fi
done

read -p "Which kernel to link? [$option]: " choice
if [ -z "$choice" ] ; then choice=$option ; fi
echo

revision=${klist[$choice]}
if [ -z "$revision" ] ; then
    echo "No valid kernel selected, exiting."
    exit
fi

if [ -d "$revision" ]; then
    echo -e "Cleaning '$out/' and copying in device tree binaries from '$revision/'"
    sudo rm -f $out/*.dtb $out/source
else
    echo "No builds found for selected kernel version: $revision"
    echo "  Try running ./make_trees.sh to generate them"
    exit 1
fi

for file in `cd "$revision" ; ls *.dtb`; do
    echo "  $cdir/$revision/$file --> $out/$file"
    sudo cp "$cdir/$revision/$file" "$out"
done

# Add a link to the output folder..
sudo ln -s "$cdir/$revision" "$out/source"

read -p "Run 'flash-kernel' to apply device tree? [Y]: " choice
if [[ "$choice" == [Yy]* ]] || [ -z "$choice" ] ; then
    echo
    sudo flash-kernel
    echo -e "\nIf flash-kernel was successful and configured properly the new device tree will be used after reboot"
else
    echo "The new device tree will be applied the next time flash-kernel is run"
fi
# fin
