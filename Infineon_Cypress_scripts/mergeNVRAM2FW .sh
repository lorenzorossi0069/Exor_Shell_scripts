#!/bin/bash

USB_FW_FILE=$1
NVRAM_FILE=$2

grep -v NVRAMRev $NVRAM_FILE > tmp_nvram.txt

./nvserial64 -a -o tmp_nvram.nvm tmp_nvram.txt

./trxv264 -f 0x20 -x `stat -c %s $USB_FW_FILE` -x 0x160881 -x `stat -c %s tmp_nvram.nvm` -o cyfmac4373.bin $USB_FW_FILE tmp_nvram.nvm

#rm tmp_nvram.txt tmp_nvram.nvm

