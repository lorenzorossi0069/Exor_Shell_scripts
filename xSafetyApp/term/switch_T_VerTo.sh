#!/bin/sh

cd /usr/bin
mount -o remount,rw /

if [[ $1 == old ]] ; then
	cp /usr/bin/safety_app_T_ORIG /usr/bin/safety_app_T	
elif [[ $1 == new ]] ; then
	cp /usr/bin/safety_app_T_new /usr/bin/safety_app_T	
elif [[ $1 == dbg ]] ; then
	cp /usr/bin/safety_app_T_DBG /usr/bin/safety_app_T	
else
	echo "Syntax: $0 <new | old | dbg>"
	exit 1
fi


echo
ps aux |  grep -e safe -e wpa | grep -v grep 
xpid=$(pidof safety_app_T)
echo "killing $xpid..."
kill $xpid
sleep 3
echo "---------------"
taskset -c 1 /usr/bin/safety_app_T -b 172.27.72.1 -1 84 -2 83 -a /dev/spidev1.0 -c /dev/spidev1.1 -f 2000000 -p 40  -s -d 
echo "restarted..."
sleep 2
