#!/bin/sh

sudo pkill hostapd
sudo pkill udhcpd

sudo pkill udhcpc
sudo pkill wpa_supplicant