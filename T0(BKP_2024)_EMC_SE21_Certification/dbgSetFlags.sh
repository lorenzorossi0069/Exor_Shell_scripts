#!/bin/sh

#define IWL_DL_INFO		0x00000001
#define IWL_DL_MAC80211		0x00000002
#define IWL_DL_EEPROM		0x00000040
#define IWL_DL_LAR		0x00004000
#define IWL_DL_11H		0x10000000

DBGFLAGS=0x10004043
#DBGFLAGS=0x10000042

echo "RAN: echo $DBGFLAGS > /sys/module/iwlwifi/parameters/debug"
echo $DBGFLAGS > /sys/module/iwlwifi/parameters/debug


