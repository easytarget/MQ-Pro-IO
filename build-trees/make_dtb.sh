#!/bin/bash
# Takes a list of dts files for the specified architecture and emits appropriate compiled dtb files for use in customised deviceTree setups.
#

dtc=/usr/bin/dtc
# alt=../alt-trees -- disabled auto building of all alt trees, better to do individually

cdir=`pwd`
versions=`dpkg --list | grep linux-image-[0-9].* | cut -d" " -s -f 3 | sed s/^linux-image-// | sort -V`

echo -ne "\nInstalled kernels: "
echo `echo $versions | sed "s/ /, /g"`

for revision in $versions ; do
    cd $cdir
    echo -e "\nCompiling against headers for $revision"

    if [ -d "$revision" ]; then
        echo "Cleaning and Using existing build directory"
        rm $revision/*.dts $revision/*.dtsi $revision/*.dtb
    else
        echo "Creating new build directory: $revision"
        mkdir "$revision"
    fi

    #echo "Copying custom dts sources to build root"
    #for dts in `ls -d $alt/*/*.dts`; do
    #    echo "$dts"
    #    cp $dts .
    #done

    echo "Precompiling all includes in build root into $revision build directory"
    for file in `ls *.dtsi`; do
        echo "  $file -> $revision/${file##*/}"
        cpp -I/usr/src/linux-headers-$revision/include/ -nostdinc -undef -x assembler-with-cpp $file > $revision/${file##*/}
    done

    echo "Precompiling all sources in build root into $revision build directory"
    for file in `ls *.dts`; do
        echo "  $file -> $revision/${file##*/}"
        cpp -I/usr/src/linux-headers-$revision/include/ -nostdinc -undef -x assembler-with-cpp $file > $revision/${file##*/}
    done

    echo "Compiling all device tree sources in $revision build directory"
    cd $revision
    for file in `ls *.dts`; do
        out=${file/.dts/.dtb}
        echo "  $revision/$file -> $revision/$revision-$out"
        $dtc $file > $revision-$out
    done
done

echo -e "\nSuccess. Consider running 'link-latest.sh' to make permanent (see docs)"
