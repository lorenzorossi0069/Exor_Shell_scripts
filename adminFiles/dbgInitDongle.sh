#!/bin/sh

#constants
MODULES_DIR=/lib/modules/$(uname -r)
TIMESERVER=DC-SERVER-03.exorint.local    
DBG_LEVEL=0x00100006

echo initialize WiFi module 2AE
#Disable RST_WIFI (gpio): (REMEMBER  must be sudo user!!)
cd /sys/class/gpio
if [[ ! -e gpio67 ]] ; then
	sudo echo 67 > export
fi
cd gpio67

#write as su on pseudofile direction  using:   sh -c '<command>'
sudo sh -c 'echo out > direction'
sudo sh -c 'echo 1 > value'

#diagnostic checks:
sudo cat direction
sudo cat value

cd $MODULES_DIR

sudo sh -c 'echo 8 > /proc/sys/kernel/printk'

sudo sh -c 'echo "---- loading compat module" > /dev/kmsg'
sudo insmod compat.ko
sleep 1

sudo sh -c 'echo "---- loading cfg80211 module" > /dev/kmsg'
sudo insmod cfg80211.ko
sleep 1

sudo sh -c 'echo "---- loading brcmutil module" > /dev/kmsg'
sudo insmod brcmutil.ko
sleep 1

echo "brcmfmac.ko has DBG_LEVEL = $DBG_LEVEL" 
sudo sh -c 'echo "---- loading  brcmfmac module"> /dev/kmsg'
sudo insmod brcmfmac.ko debug=$DBG_LEVEL alternative_fw_path=cytest
sleep 1

echo Synchronize date and time
sudo ntpdate $TIMESERVER

