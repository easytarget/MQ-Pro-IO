#!/bin/bash
# Takes a list of dts files for the specified architecture and emits appropriate compiled dtb files for use in customised deviceTree setups.
#

dtc=/usr/bin/dtc

cdir=`pwd`
versions=`dpkg --list | grep linux-image-[0-9].* | cut -d" " -s -f 3 | sed s/^linux-image-// | sort -V`
current=`/usr/bin/uname -r`

read -p "Update source tree (may be slow)? [y/N]: " choice
if [ ! -z "$choice" ] ; then
    if [ "$choice" == 'y' ] ; then
        cd ../source
        apt source linux-riscv
    fi
fi

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

read -p "Which kernel to build? [$option]: " choice
if [ -z "$choice" ] ; then
    choice=$option
else
    echo
    echo "WARNING: building older versions may fail if the source tree includes have changed with more recent kernels"
    echo
fi

revision=${klist[$choice]}
if [ -z "$revision" ] ; then
    echo "No valid kernel selected, exiting."
    exit
fi

echo -ne "\nBuilding for kernel: $revision"
echo

# Ensure sure build root exists and is clean
if [ -d "$cdir/$revision" ]; then
    echo "Cleaning existing $revision build directory"
    rm -f $revision/*.dts $revision/*.dtsi $revision/*.dtb
else
    echo "Creating new build directory: $revision"
    mkdir $revision
fi

# Compile
cd $cdir
echo -e "\nCompiling against headers for $revision"
echo "Precompiling all includes in build root into $revision build directory"

for file in `ls *.dtsi`; do
echo "  $file -> $revision/${file##*/}"
cpp -I/usr/src/linux-headers-$revision/include/ -nostdinc -undef -x assembler-with-cpp $file > $revision/${file##*/}
if [ ! -s "$revision/${file##*/}" ] ; then
    rm "$revision/${file##*/}"
    echo "**** ERROR ****"
    echo "Precompile failed for include: $revision/${file##*/}"
    exit 1
fi
done

echo "Precompiling all sources in build root into $revision build directory"
for file in `ls *.dts`; do
echo "  $file -> $revision/${file##*/}"
cpp -I/usr/src/linux-headers-$revision/include/ -nostdinc -undef -x assembler-with-cpp $file > $revision/${file##*/}
if [ ! -s "$revision/${file##*/}" ] ; then
    rm "$revision/${file##*/}"
    echo "**** ERROR ****"
    echo "Precompile failed for source: $revision/${file##*/}"
    exit 1
fi
done

echo "Compiling all device tree sources in $revision build directory"
cd $revision
for file in `ls *.dts`; do
out=${file/.dts/.dtb}
echo "  $revision/$file -> $revision/$out"
$dtc $file > $out
if [ ! -s "$out" ] ; then
    rm "$out"
    echo "**** ERROR ****"
    echo "Compile failed for: $out"
    exit 1
fi
done

echo -e "\nSuccess. Consider running 'flash_latest.sh' to make permanent (see docs)"
