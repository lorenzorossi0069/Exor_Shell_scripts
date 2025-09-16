#!/bin/sh
echo
echo "set AP"
echo

sudo pkill wpa_supplicant
sudo pkill hostapd
sudo pkill udhcpd

#echo "activate debug for AP"
#./dbgSetFlags.sh
sleep 1

sudo ifconfig wlan0 111.112.113.1 netmask 255.255.255.0 up
#sudo hostapd -B /etc/hostapd.conf -ddd
sudo hostapd -B /etc/hostapd.conf 
sudo udhcpd -S -I 111.112.113.1  /etc/udhcpd.conf



