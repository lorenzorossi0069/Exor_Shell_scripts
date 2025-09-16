#!/bin/sh
if [[ $1=='' ]] ; then
	N='X'
else
	N=$1
fi

echo "you should have given \"echo 0x4000 > /sys/module/iwlwifi/parameters/debug\""
echo 0x4000 > /sys/module/iwlwifi/parameters/debug

#cat /var/volatile/log/messages > /mnt/data/messages$1.npp
#dmesg --notime -c > /mnt/data/crda-dmesg$1.npp
#u sort
dmesg --notime -c |sort -u > /mnt/data/crda-dmesg$1.npp




