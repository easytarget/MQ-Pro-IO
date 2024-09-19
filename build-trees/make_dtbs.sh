#!/bin/bash
# Takes a list of dts files for the specified architecture and emits appropriate compiled dtb files for use in customised deviceTree setups.
#

dtc=/usr/bin/dtc

cdir=`pwd`
versions=`dpkg --list | grep linux-image-[0-9].* | cut -d" " -s -f 3 | sed s/^linux-image-// | sort -V`

echo -ne "\nBuilding for kernels: "
echo `echo $versions | sed "s/ /, /g"`
echo

# Disabled auto building of all alt trees, better to do individually
#alt=../alt-trees
#echo "Linking alt dts sources to build root"
#for dts in `ls -d $alt/*/*.dts`; do
#    echo "$dts"
#    ln -s "$dts" .
#done

# Ensure sure build roots exist and are clean
for revision in $versions ; do
    if [ -d "$cdir/$revision" ]; then
        echo "Cleaning existing $revision build directory"
        rm -f $revision/*.dts $revision/*.dtsi $revision/*.dtb
    else
        echo "Creating new build directory: $revision"
        mkdir $revision
    fi
done

# Compile for each revision
for revision in $versions ; do
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
done

echo -e "\nSuccess. Consider running 'flash_latest.sh' to make permanent (see docs)"
