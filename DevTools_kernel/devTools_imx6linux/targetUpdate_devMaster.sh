#!/bin/sh

mount -o remount,rw /

echo "for arm64 name is: Image (else TBD zImage)"

cp Image /boot
cp newModules.gz /lib/modules

echo "untar new modules install tree"
cd /lib/modules
rm -rf 5.10.*
tar xvf newModules.gz 
sleep 1

rm newModules.gz 
sleep 1

sync
echo "press ENTER to reboot"
read dummy
reboot

