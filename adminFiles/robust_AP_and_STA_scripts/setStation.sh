#!/bin/sh

sudo pkill wpa_supplicant

# wait until it's really gone
while pidof wpa_supplicant > /dev/null; do sleep 0.2; done

# optional but STRONGLY recommended
ip link set wlan0 down
sleep 0.5
ip link set wlan0 up

# cleanup stale control socket
rm -f  /run/wpa_supplicant/wlan0

# If you also run a DHCP client make sure you kill that too before restarting supplicant
# or
# for static IP:
sudo ifconfig wlan0 172.27.72.2 netmask 255.255.255.0

##sleep 1
sudo wpa_supplicant-openssl -B -i wlan0 -c wpa_supplicant.conf 

