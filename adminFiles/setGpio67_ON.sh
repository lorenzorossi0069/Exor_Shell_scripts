#/bin/sh

#constants
MODULES_DIR=/lib/modules/$(uname -r)
TIMESERVER=DC-SERVER-03.exorint.local    

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

echo "enable debg msgs in printk"
cd $MODULES_DIR
#echo 7 > /proc/sys/kernel/printk


echo Synchronize date and time
sudo ntpdate $TIMESERVER

