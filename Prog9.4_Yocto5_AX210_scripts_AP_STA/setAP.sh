#!/bin/sh

sudo pkill hostapd

#pkill sends SIGTERM, but AP does not die immediately
#so wait:
while pidof hostapd > /dev/null; do sleep 0.2; done

#and do also an interface reset:
ip link set wlan0 down
sleep 1 
ip link set wlan0 up
sleep 1 

# If you also run a DHCP client make sure you kill that too before restarting supplicant
# or
# for static IP:
sudo ifconfig wlan0 172.27.72.1 netmask 255.255.255.0

#now hostapd can be restarted
sudo hostapd -i wlan0  -B  ./hostapd_pairingTestApp.conf 

