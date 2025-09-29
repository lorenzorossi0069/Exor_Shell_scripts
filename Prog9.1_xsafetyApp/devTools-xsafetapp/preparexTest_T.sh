#!/bin/sh

sudo mount -o remount,rw /

cd /mnt/data

chown root:root safety_app_T
chmod +x safety_app_T
mv /mnt/data/safety_app_T /usr/bin

chown root:root safety_app_B
chmod +x safety_app_B
mv /mnt/data/safety_app_B /usr/bin

chown root:root pairingTestApp
chmod +x pairingTestApp
mv /mnt/data/pairingTestApp /home/admin

chown root:root unpairingTestApp
chmod +x unpairingTestApp
mv /mnt/data/unpairingTestApp /home/admin

echo "restart safetApp_T"
echo
ps aux |  grep safe  | grep -v grep
xpid=$(pidof safety_app_T)
echo "killing $xpid..."
kill $xpid
sleep 3
echo "---------------"
taskset -c 1 /usr/bin/safety_app_T -b 172.27.72.1 -1 84 -2 83 -a /dev/spidev1.0 -c /dev/spidev1.1 -f 2000000 -p 40 &
echo "restarted..."
sleep 2
