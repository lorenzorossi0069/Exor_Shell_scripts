#!/bin/sh

#constants
MODULES_DIR=/lib/modules/$(uname -r)

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
