#!/bin/bash

MODE=$1

INTERFACE=wlan0
#CHANNEL=(see hostapd.conf)
#BANDWIDTH=HT20
TXPOWER=2000

#======================================================
echo "MODE is $MODE"

if [ "$MODE" == "ap"  ] ; then
  ./setAP.sh
  
elif [ "$MODE" == "virt"  ] ; then
  echo connecting to virtual station
  pkill wpa_supplicant
  pkill hostapd
  pkill udhcpd
  
  #echo "activate debug for AP"
  #./dbgSetFlags.sh
  sleep 1
  
  ifconfig wlan0 111.112.113.1 netmask 255.255.255.0 up
  hostapd -B /etc/hostapd.conf  

  iw dev sta0 del
  iw dev wlan0 interface add sta0 type station
  ifconfig sta0 111.112.113.3 netmask 255.255.255.0 up
  sleep 1
  echo dummy 3;read dummy
  
  sudo wpa_supplicant -B -ista0 -c/etc/wpa_supplicant_VirtualSta.conf
  
  sleep 1
  echo dummy 4;read dummy
  
  
#echo dummy 1bis;read dummy
#  iw dev wlan0 interface add mon0 type monitor
#echo dummy 2;read dummy
#  iw dev mon0 set channel 3
#echo dummy 3;read dummy
#  ip link set mon0 up
 echo dummy 5;read dummy


#elif [ "$MODE" == "monitor"  ] ; then
#  ip link set wlan0 down
#  iw dev wlan0 set type $MODE
#  ip link set wlan0 up
#  ifconfig wlan0 111.112.113.1 netmask 255.255.255.0 up

elif [ "$MODE" == "ibss"  ] ; then
  ip link set wlan0 down
  echo "set mode $MODE"
  iw dev wlan0 set type $MODE
  ip link set wlan0 up
  ifconfig wlan0 111.112.113.1 netmask 255.255.255.0 up
  iw dev wlan0 ibss join my_ibss_network 2422

else 
  echo -n "no mode selected: press enter to continue... "
  read dummy
fi
	
#==========================================================

#iw dev $INTERFACE set channel $CHANNEL $BANDWIDTH
#iw dev $INTERFACE set channel $CHANNEL
#echo read dummy b; read  dummy

# Configura la potenza di trasmissione (facoltativo, controlla la regolamentazione locale)
iw dev $INTERFACE set txpower fixed $TXPOWER

echo "L'interfaccia $INTERFACE è stata configurata per la trasmissione continua con potenza $TXPOWER"
#-------------

PGDEV_K0=/proc/net/pktgen/kpktgend_0
sudo echo "rem_device_all" > $PGDEV_K0
sudo echo "add_device wlan0" > $PGDEV_K0

PGDEV_WLAN0=/proc/net/pktgen/wlan0
sudo echo "count 0" > $PGDEV_WLAN0           # 0 means indefinitely
sudo echo "clone_skb 0" > $PGDEV_WLAN0       # No packet cloning
sudo echo "pkt_size 512" > $PGDEV_WLAN0      # Size of each packet
sudo echo "delay 0" > $PGDEV_WLAN0
sudo echo "flag NO_TIMESTAMP" > $PGDEV_WLAN0 # Disable timestamping

if [ "$MODE" == "ap"  ] ; then
 
  #sudo echo "dst 111.112.113.2" > $PGDEV_WLAN0 
  #sudo echo "dst_mac a8:41:f4:f3:6c:77" > $PGDEV_WLAN0 
  sudo echo "dst 111.112.113.255" > $PGDEV_WLAN0 
  sudo echo  "dst_mac ff:ff:ff:ff:ff:ff" > $PGDEV_WLAN0
  
elif [ "$MODE" == "virt"  ] ; then
  sudo echo "dst 111.112.113.3" > $PGDEV_WLAN0 
  sudo echo "dst_mac 8c:b8:7e:cf:a5:a4" > $PGDEV_WLAN0 
fi 

PGDEV_PGCTRL=/proc/net/pktgen/pgctrl
echo "Start packet generation (to $PGDEV_PGCTRL )"

echo press enter to start; read  dummy
sudo echo "start" > $PGDEV_PGCTRL &

echo press enter to stop; read  dummy
sudo echo "stop" > $PGDEV_PGCTRL

sssss


 
sudo echo "dst 111.112.113.2" > $PGDEV_WLAN0   
sudo echo "dst_mac a8:41:f4:f3:6c:77" > $PGDEV_WLAN0  

