#!/bin/sh

ip link show wlan0
echo "-----"
ifconfig wlan0
echo "-----"
iw dev wlan0 station dump
echo "-----"

