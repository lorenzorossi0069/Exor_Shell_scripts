#!/bin/sh

if [[ $# < 1 ]] ; then
	echo "Error:"
	echo "$0 <arm32/arm64>"
	exit 1
fi

armHW=$1

if [[ $armHW == arm64 ]] ; then
	echo "upgrade Kernel for arm64"
	bootImageName=Image
elif [[ $armHW == arm32 ]] ; then
	echo "upgrade Kernel for arm32"
	bootImageName=zImage
else
	echo "arg 1 must be arm32 or arm64"
	exit 1
fi

SETUPDIR=$PWD

mount -o remount,rw /

if [[ ! -e $SETUPDIR/$bootImageName ]] ; then
	echo "$bootImageName not found in $SETUPDIR"
	exit 1
fi


cd /boot
rm $bootImageName
cp $SETUPDIR/$bootImageName .
echo "Upgrading DeviceTrees"
cp $SETUPDIR/ns02_wu07.dtb .
cp $SETUPDIR/ns02_wu20.dtb .
sync

echo "Press enter to reboot with new kernel"; read dummy

reboot

