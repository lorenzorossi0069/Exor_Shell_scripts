#!/bin/sh

sudo mount -o remount,rw /

cd /mnt/data

chown root:root safety_app_T_new
chmod +x safety_app_T_new
mv /mnt/data/safety_app_T_new /usr/bin

chown root:root pairingTestApp
chmod +x pairingTestApp
mv /mnt/data/pairingTestApp /home/admin

chown root:root unpairingTestApp
chmod +x unpairingTestApp
mv /mnt/data/unpairingTestApp /home/admin

/home/admin/switch_T_VerTo.sh new

