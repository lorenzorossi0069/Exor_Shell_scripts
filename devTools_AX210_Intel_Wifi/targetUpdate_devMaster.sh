#!/bin/sh

mount -o remount,rw /

echo "for arm64 name is: Image (else TBD zImage)"
mv Image /boot
mv newModules.gz /lib/modules

echo "untar new modules install tree"
cd /lib/modules
tar xvf newModules.gz 
sleep 1

rm newModules.gz 
sleep 1

sync
echo "press ENTER to reboot"
read dummy
reboot



