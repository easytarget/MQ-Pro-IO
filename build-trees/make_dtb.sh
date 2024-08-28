#!/bin/bash
# Takes a list of dts files for the specified architecture and emits appropriate compiled dtb files for use in customised deviceTree setups.
#

dtc=/usr/bin/dtc
revision=`/usr/bin/uname -r`
trees=../precompiled-trees

echo "Compiling against headers for $revision"

if [ -d "$revision" ]; then
    echo "Cleaning and Using existing build directory"
    rm "$revision/*.dts $revision/*.dtsi $revision/*.dtb"
else
    echo "Creating new build directory: $revision"
    mkdir "$revision"
fi

echo "Copying custom dts sources to build root"
for dts in `ls -d $trees/*/*.dts`; do
    echo "$dts"
    cp $dts .
done

echo "Precompiling all includes and sources in build root into $revision build directory"
for file in `ls {*.dts,*.dtsi}`; do
    echo "Processing $file to $revision/${file##*/}"
    cpp -I/usr/src/linux-headers-$revision/include/ -nostdinc -undef -x assembler-with-cpp $file > $revision/${file##*/}
done

echo "Compiling all device tree sources in $revision build directory"
cd $revision
for file in `ls *.dts`; do
    out=${file/.dts/.dtb}
    echo "Compiling: $revision/$file > $revision/$out"
    $dtc $file > $out
done