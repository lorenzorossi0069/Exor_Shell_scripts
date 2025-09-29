#!/bin/sh

watch -n 0.5 'ps aux | grep -e wpa  | grep -v grep ; echo ----; ifconfig wlan0 ; iw wlan0 link '

