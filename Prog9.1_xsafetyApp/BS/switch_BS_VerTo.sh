#!/bin/sh

cd /usr/bin
mount -o remount,rw /

if [[ $1 == old ]] ; then
        cp /usr/bin/safety_app_B_ORIG /usr/bin/safety_app_B
elif [[ $1 == new ]] ; then
        cp /usr/bin/safety_app_B_new /usr/bin/safety_app_B
elif [[ $1 == dbg ]] ; then
        cp /usr/bin/safety_app_B_DBG /usr/bin/safety_app_B

else
        echo "Syntax: $0 <new | old | dbg>"
        exit 1
fi


echo
ps aux | grep safe
xpid=$(pidof safety_app_B)
echo "killing $xpid..."
kill $xpid
sleep 3
echo "---------------"
/usr/bin/safety_app_B -t 172.27.72.2 -1 155 -2 154 -3 7 -4 5 -a /dev/spidev0.0 -b /dev/spidev0.1 -f 2000000 -p 40 -d -s 
echo "restarted..."
sleep 2

