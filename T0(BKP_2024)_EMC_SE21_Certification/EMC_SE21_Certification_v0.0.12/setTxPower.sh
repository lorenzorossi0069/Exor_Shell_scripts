#!/bin/bash

val=$1

#note: with AX210 max is 2100 (22.00 dBm), bigger values are clamped

if [[ $val == "" ]] ; then
#if [ -z "$val" ]; then
  echo "must insert a value [100 - 2200] (=> dBm*100).. Exit"
  echo "Tx power left to: $(iw wlan0 info | grep -i power)"
  exit 1
fi


iw dev wlan0 set txpower fixed $val

echo "Tx power set to: $(iw wlan0 info | grep -i power)"
