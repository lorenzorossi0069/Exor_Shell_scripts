#!/bin/sh

mount -o remount,rw /

cp -r /mnt/data/updatesKmod /lib/modules/5.10.*/
cp /mnt/data/iwlwifi-* /lib/firmware/.

sync

echo 'running: depmod -a $(uname -r)  #(not sure must be done after reboot)'
depmod -a $(uname -r)

echo "press ENTER to reboot"
read dummy
reboot

