#!/bin/sh

#do not change order of lines
source ./commonSettings.sh
source ./libFunctions.sh

Detected_MAC=$(cat /sys/class/net/wlan0/address)

if [[ $DEST_MAC != $Detected_MAC ]]  ; then 
  echo "------------------------------------"
  echo "ERROR: Station MAC address ($Detected_MAC) is not as expected (changed Station HW?)"
  echo "Please edit ./commonSettings.sh file in both AP and STAtion boards"
  echo "and replace (in both machines!) DEST_MAC=$Detected_MAC"
  echo "------------------------------------"
  exit 1
fi 
echo "-----------------------------------------------"
echo "Station, with MAC address = $Detected_MAC"
echo "-----------------------------------------------"

#pkill instead of kill to use name instead of PID
pkill wpa_supplicant
pkill hostapd
pkill udhcpc
pkill udhcpd

ip link set wlan0 down
ifconfig wlan0 $FIXED_STA_IP  netmask 255.255.255.0 up

[[ ! -e $WPA_SUPPLICANT_FILE ]] && echo "file not found: $WPA_SUPPLICANT_FILE" && exit 1
sed -i "s/^country=.*/country=$COUNTRY/" $WPA_SUPPLICANT_FILE
wpa_supplicant -B -iwlan0 -c $WPA_SUPPLICANT_FILE

#monitor connection status and RX packet
echo press ENTER to start WATCH on Sta ; read dummy
watch -n 0.2 iw dev wlan0 link


