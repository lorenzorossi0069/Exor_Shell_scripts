#!/bin/sh

#do not change order of lines
source ./commonSettings.sh
source ./libFunctions.sh

trap terminateEmission SIGINT

if [ "$#" -ne 4 ] ; then
    echo "ERROR: must have 3 args: $0 <firstCPU[0-3]> <lastCPU[0-3]> <100*dBm[100-2200]> <Channel> .. Exiting.."
    exit 1
fi

FIRST_CPU=$1
LAST_CPU=$2
TXPOWER=$3
CHANNEL=$4

if (( $FIRST_CPU > $LAST_CPU )); then
	auxVal=$FIRST_CPU
	FIRST_CPU=$LAST_CPU
	LAST_CPU=$auxVal
fi

#---------------------
if [[ $(lsmod | grep pktgen) == "" ]] ; then
  #load module if not found
  insmod /lib/modules/pktgen.ko
fi

#---------------------
#set AP (without DHCP)

iw dev wlan0 set power_save off #must be set before starting hostapd 

pkill wpa_supplicant
pkill hostapd
pkill udhcpc
pkill udhcpd

ip link set wlan0 down
ifconfig wlan0 $FIXED_AP_IP netmask 255.255.255.0 up

[[ ! -e $HOSTAPD_FILE ]] && echo "file not found: $HOSTAPD_FILE" && exit 1
sed -i "s/^channel=.*/channel=$CHANNEL/" $HOSTAPD_FILE
sed -i "s/^country_code=.*/country_code=$COUNTRY/" $HOSTAPD_FILE
#hostapd -B  -i wlan0 $HOSTAPD_FILE
hostapd -B  $HOSTAPD_FILE

#syntax: dev wlan0 set txpower <auto|fixed|limit> [<tx power in mBm>]
iw dev wlan0 set txpower fixed $TXPOWER #can be set after starting hostapd

echo "--- txpower settings: ---"
echo "        $(iw dev wlan0 get power_save)"
echo "$(iw wlan0 info | grep -i power)"
echo " -------------------------"

for ((thread = $FIRST_CPU; thread <= $LAST_CPU; thread++)); do
  PGDEV_Kn=/proc/net/pktgen/kpktgend_${thread}
  dev=wlan0@cpu${thread}
  echo "rem_device_all" > $PGDEV_Kn 
  echo "add_device $dev" > $PGDEV_Kn

#-------------------------------------
  PGDEV_WLANn=/proc/net/pktgen/$dev
  
  echo "count 0" > $PGDEV_WLANn           # 0 means indefinitely
  echo "clone_skb 0" > $PGDEV_WLANn       # deprecated
  echo "pkt_size 1024" > $PGDEV_WLANn     # no more than 1024
  # echo "burst 4" > $PGDEV_WLANn 
  # echo "frags 10" > $PGDEV_WLANn
  # echo "rate 300" > $PGDEV_WLANn
  # echo "ratep 1000000" > $PGDEV_WLANn
  echo "delay 0" > $PGDEV_WLANn  
  
  #echo "dst 111.112.113.2" > $PGDEV_WLANn 

# echo "udp" > $PGDEV_WLANn
# echo "dst_ip 111.112.113.2"  > $PGDEV_WLANn

##RSI
# echo "dst_mac 04:cd:15:14:a5:00" > $PGDEV_WLANn
##AW64
 ##GOOD##
 #echo "dst_mac a8:41:f4:f3:6c:77" > $PGDEV_WLANn
 echo "dst_mac $DEST_MAC" > $PGDEV_WLANn

 #test MAC
 #echo "dst_mac FF:FF:FF:FF:FF:FF" > $PGDEV_WLANn
##SE21
# echo "dst_mac 8c:b8:7e:cf:a5:a3" > $PGDEV_WLANn


  #echo "udp_src_min 1234" > $PGDEV_WLANn    # Porta sorgente
  #echo "udp_dst_min 5678" > $PGDEV_WLANn    # Porta di destinazione  
  
  echo "flag NO_TIMESTAMP" > $PGDEV_WLANn # Disable timestamping
  #### echo "flag QUEUE_MAP_CPU" > $PGDEV_WLANn # Disable timestamping

done

### askif exit test
#testexit='1'
#echo -n "enter k to kill immediately (WITHOUT DELETING FILES)"
#read testexit
#if [[ $testexit == 'k' ]] ;  then
#  exit
#fi


echo "wait Station connection and then press enter to start"; read  dummy

PGDEV_PGCTRL=/proc/net/pktgen/pgctrl
echo "start" > $PGDEV_PGCTRL &

echo press enter to stop; read  dummy
echo "stop" > $PGDEV_PGCTRL

#cancel thread files
for ((thread = $FIRST_CPU; thread <= $LAST_CPU; thread++)); do
  dev=wlan0@cpu${thread}
  PGDEV_Kn=/proc/net/pktgen/kpktgend_${thread}
   echo "rem_device_all" > $PGDEV_Kn 
done

terminateEmission

  


