#!/bin/sh
cd /sys/class/gpio/gpio67
echo "now in $(pwd)"

echo out > direction
echo 0 > value
sleep 1
echo 1 > value
sleep 1

#echo
#cd /lib/modules/$(uname -r) 
#echo "now in $(pwd)"
#rmmod kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
#rmmod kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko
#rmmod kernel/net/wireless/cfg80211.ko
#sleep 1
#insmod kernel/net/wireless/cfg80211.ko
#insmod kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko
#insmod kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko

echo 
sleep 1
lsmod
wl ver
wl clmver
wl country

mount -o remount,rw /

