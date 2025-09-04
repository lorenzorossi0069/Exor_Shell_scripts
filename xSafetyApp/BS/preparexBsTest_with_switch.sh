#!/bin/sh

sudo mount -o remount,rw /

cd /mnt/data

chown root:root safety_app_B_new
chmod +x safety_app_B_new
mv /mnt/data/safety_app_B_new /usr/bin

/home/admin/switch_BS_VerTo.sh new

