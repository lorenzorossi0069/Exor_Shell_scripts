#!/bin/sh
if [[ $1=='' ]] ; then
	N='X'
else
	N=$1
fi

echo 0x4000 > /sys/module/iwlwifi/parameters/debug
sleep 1

#cat /var/volatile/log/messages > /mnt/data/messages$1.npp
dmesg --notime -c | sort -u > /mnt/data/uSortDmesg$1.npp




