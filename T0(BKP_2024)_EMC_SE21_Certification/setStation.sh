#!/bin/sh

echo
echo "configure as STAtion"
echo

#pkill instead of kill to use name instead of PID
sudo pkill wpa_supplicant
sudo pkill udhcpc

sudo pkill hostapd
sudo pkill udhcpd

sudo ifconfig wlan0 up
#sudo ifconfig wlan0 111.112.113.2 netmask 255.255.255.0 up

#sudo wpa_supplicant -B -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf
sudo wpa_supplicant -B -iwlan0 -c/etc/wpa_supplicant.conf
sleep 1

#launch DHCP Client
udhcpc -i wlan0 
sleep 1

#let some time for connection
echo INFO: you can check connection with: iw dev wlan0 link
echo
sleep 1
watch -n 1 iw dev wlan0 link

