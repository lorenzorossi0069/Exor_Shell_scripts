#!/bin/sh
echo
echo "set AP"
echo

sudo pkill hostapd
sudo pkill wpa_supplicant
sudo pkill udhcpd
sleep 1

echo set IP address of this AP: 111.112.113.1 netmask 255.255.255.0
sudo ifconfig wlan0 111.112.113.1 netmask 255.255.255.0 up

sudo iw dev wlan0 interface add wlan0 type ap
sleep 1

sudo hostapd -B /etc/hostapd.conf

echo start DHCP Server for this AP
sudo udhcpd -S -I 111.112.113.1  /etc/udhcpd.conf

echo "AP activated"
