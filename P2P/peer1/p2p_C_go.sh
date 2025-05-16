#!/bin/sh

source ./p2p_common.sh

ifconfig $IFACE 201.202.203.1  netmask 255.255.255.0

p2p_startWPAsupplicant

#p2p_group_add: create virtual group interface
wpa_cli -i $IFACE p2p_group_add > /dev/null

echo -n "Insert PIN: "
read PIN_C
wpa_cli -i $GROUP_IFACE wps_pin any $PIN_C

echo debug begin
wpa_cli interface
echo debug begin
read dummy

GROUP_IFACE=$(wpa_cli interface | grep p2p-wlan | grep -v interface)
ifconfig $GROUP_IFACE 151.152.153.1


#GROUP_IFACE=$(wpa_cli interface | grep p2p-wlan | grep -v Selected)
#echo "[GO] Connected by interface: $GROUP_IFACE"

echo "[GO] Infos:  $GROUP_IFACE"
wpa_cli -i $GROUP_IFACE status

sleep 3 
echo -n "press enter to test ping on oyher peer"; read pressEnter
echo
ping -c 3 151.152.153.2




