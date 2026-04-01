sudo pkill hostapd

#pkill sends SIGTERM, but AP does not die immediately
#so wait:
while pidof hostapd > /dev/null; do sleep 0.2; done

#and do also an interface reset:
ip link set wlan0 down
sleep 1 
ip link set wlan0 up

#now hostapd can be restarted
sudo hostapd -i wlan0  -B  ./hostapd.conf 



