rm -f dtbs/*
for file in `ls ../{*.dts,*.dtsi}`; do
	echo "Processing $file to ${file##*/}"
	cpp -I/usr/src/linux-headers-6.8.0-31-generic/include/ -nostdinc -undef -x assembler-with-cpp $file > ${file##*/}
done
