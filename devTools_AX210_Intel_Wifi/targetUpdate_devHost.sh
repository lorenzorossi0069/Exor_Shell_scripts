#!/bin/sh

mount -o remount,rw /

echo "for arm64 name is: Image (else TBD zImage)"
mv Image /boot
mv modules.gz /

echo "untar new modules install tree"
cd /
tar xvf modules.gz 

sleep 1
sync
echo "press ENTER to reboot"
read dummy
reboot



