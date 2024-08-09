#!/bin/bash
# Takes a list of dts files for the specified architecture and emits appropriate compiled dtb files for use in customised deviceTree setups.
#

dtc=/usr/bin/dtc
revision=`/usr/bin/uname -r`

echo "Compiling against headers for $revision"

if [ -d "$revision" ]; then
    echo "Using existing build directory"
else
    echo "Creating new build directory"
    mkdir "$revision"
fi

for file in `ls {*.dts,*.dtsi}`; do
    echo "Processing $file to ${file##*/}"
    cpp -I/usr/src/linux-headers-$revision/include/ -nostdinc -undef -x assembler-with-cpp $file > $revision/${file##*/}
done

cd $revision
for file in `ls *.dts`; do
    out=${file/.dts/.dtb}
    echo "Compiling: $revision/$file > $revision/$out"
    $dtc $file > $out
done
