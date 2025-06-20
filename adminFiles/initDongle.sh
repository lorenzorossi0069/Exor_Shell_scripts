#!/bin/sh

#constants
MODULES_DIR=/lib/modules/$(uname -r)
TIMESERVER=DC-SERVER-03.exorint.local    

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

#WiFi Modules

sudo insmod compat.ko
sudo insmod cfg80211.ko
sudo insmod brcmutil.ko
sudo insmod brcmfmac.ko

echo "exit without loading BT"
exit 0

#BT modules
sudo insmod ecc.ko

sudo insmod ecdh_generic.ko

sudo insmod bluetooth.ko

sudo insmod btrtl.ko
sudo insmod btbcm.ko
sudo insmod btintel.ko

sudo insmod btusb.ko


echo Synchronize date and time
sudo ntpdate $TIMESERVER

