for file in `ls *.dts*` ; do
	echo $file
	cpp -I/usr/src/linux-headers-6.8.0-31-generic/include/ -nostdinc -undef -x assembler-with-cpp $file > dtspp/$file
done
