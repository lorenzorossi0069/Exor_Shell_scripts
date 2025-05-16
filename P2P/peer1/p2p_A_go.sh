#!/bin/sh

source ./p2p_common.sh

ifconfig $IFACE 201.202.203.1  netmask 255.255.255.0

p2p_startWPAsupplicant

wpa_cli -i $IFACE p2p_group_add > /dev/null

# Set group interface on this peer
GROUP_IFACE=$(wpa_cli interface | grep p2p-wlan | grep -v interface)
ifconfig $GROUP_IFACE 151.152.153.1

echo "press WPS button (i.e. enter)..."; read waitPressButton
wpa_cli -i $GROUP_IFACE wps_pbc

# find selected interface
GROUP_IFACE=$(wpa_cli interface | grep p2p-wlan | grep -v Selected)
echo "[GO] Connected by : $GROUP_IFACE"

echo "[GO] Infos:  $GROUP_IFACE"
wpa_cli -i $GROUP_IFACE status




