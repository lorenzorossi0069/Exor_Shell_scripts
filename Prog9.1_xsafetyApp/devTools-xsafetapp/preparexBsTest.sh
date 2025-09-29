#!/bin/sh

sudo mount -o remount,rw /

cd /mnt/data

chown root:root safety_app_B
chmod +x safety_app_B
mv /mnt/data/safety_app_B /usr/bin

chown root:root safety_app_T
chmod +x safety_app_T
mv /mnt/data/safety_app_T /usr/bin


echo "restart new safetyApp_B"
echo
ps aux | grep safe | grep -v grep
xpid=$(pidof safety_app_B)
echo "killing $xpid..."
kill $xpid
sleep 3
echo "---------------"
/usr/bin/safety_app_B -t 172.27.72.2 -1 155 -2 154 -3 7 -4 5 -a /dev/spidev0.0 -b /dev/spidev0.1 -f 2000000 -p 40 &
echo "restarted..."
sleep 2

