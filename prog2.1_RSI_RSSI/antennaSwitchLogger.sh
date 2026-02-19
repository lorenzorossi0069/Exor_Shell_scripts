#!/bin/sh
source ./params_AntennaSwitch.txt
logfile=logfile_antennaSwitch_$(date +"%Y-%m-%d_h%H_%M_%S").log
touch logfile

while true; do


	dmesg -c | grep 
	
	nowIs=$(date +"%Y-%m-%d_h%H_%M_%S")
    val=$(iw dev wlan0 link | awk '/signal/ {print $2}')
	if (( $val<=-80 )) ; then
		echo "$nowIs: low value of RSSI: $val" 
		echo "$nowIs: low value of RSSI: $val" >> $logfile
	fi
    sleep 1
done

