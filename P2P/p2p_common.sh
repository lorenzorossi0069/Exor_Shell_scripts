#!/bin/sh
#common P2P constants and functions

IFACE=wlan0
WPA_SUPPLICANT_PATH=wpa_supplicant_p2p.conf


function p2p_cleanUp {
	#for TEMP_IFACE in $(wpa_cli interface | grep p2p-); do
	#    echo "Removing $TEMP_IFACE"
	#    wpa_cli p2p_group_remove $TEMP_IFACE
	#done
	
	echo "Cleaning IFACE=$IFACE"
	
	wpa_cli -i $IFACE p2p_flush
	
	wpa_cli -i $IFACE remove_network all
}

function p2p_killAll {
	p2p_cleanUp
	pkill wpa_supplicant
	pkill hostapd
	sleep 2
}

function p2p_startWPAsupplicant {
	p2p_killAll
	wpa_supplicant -B -i $IFACE -c $WPA_SUPPLICANT_PATH
}



