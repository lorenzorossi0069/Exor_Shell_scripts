#!/bin/sh

echo
echo "configure as STAtion"
echo

#pkill instead of kill to use name instead of PID
sudo pkill wpa_supplicant
sudo pkill hostapd
sudo pkill udhcpc

sudo ifconfig wlan0 up
sleep 1

sleep 1
#sudo wpa_supplicant -B -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf
sudo wpa_supplicant -B -iwlan0 -c/etc/wpa_supplicant.conf
sleep 1



#echo Assign static IP: 172.27.73.99 / 255.255.255.0
#sudo ifconfig wlan0 172.27.73.99 netmask 255.255.255.0
#launch DHCP Client
udhcpc -i wlan0 
sleep 1

#let some time for connection
echo INFO: you can check connection with: iw dev wlan0 link
echo

