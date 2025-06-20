#!/bin/sh

cd /lib/modules/$(uname -r)

##BT modules
#sudo rmmod btusb.ko
#sudo rmmod btintel.ko
#sudo rmmod btbcm.ko
#sudo rmmod btrtl.ko
#sudo rmmod bluetooth.ko
#sudo rmmod ecdh_generic.ko
#sudo rmmod ecc.ko

#WiFi modules
sudo rmmod brcmfmac.ko
sudo rmmod brcmutil.ko
sudo rmmod cfg80211.ko
sudo rmmod compat.ko
