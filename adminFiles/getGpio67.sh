#!/bin/sh

cd /sys/class/gpio
if [[ ! -e gpio67 ]] ; then
	sudo echo 67 > export
fi
cd gpio67

echo "gpio67 value = $(cat value)"


