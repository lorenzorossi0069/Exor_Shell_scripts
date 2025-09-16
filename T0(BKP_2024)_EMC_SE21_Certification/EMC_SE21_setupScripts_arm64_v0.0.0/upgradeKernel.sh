#!/bin/sh

SETUPDIR=$PWD

mount -o remount,rw /

if [[ ! -e $SETUPDIR/Image ]] ; then
	echo "Image not found in $SETUPDIR"
	exit 1
fi


cd /boot
rm Image
cp $SETUPDIR/Image .
cp $SETUPDIR/pktgen.ko /lib/modules/
sync

echo "Press enter to reboot with new kernel"; read dummy

reboot

