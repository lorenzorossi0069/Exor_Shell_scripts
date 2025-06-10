#!/bin/sh

echo 8 > /proc/sys/kernel/printk
sleep 1

#    insmod /lib/modules/$(uname -r)/kernel/net/wireless/compat.ko  debug=0x001FFFFE
    insmod /lib/modules/$(uname -r)/kernel/net/wireless/cfg80211.ko  debug=0x001FFFFE
#    insmod /lib/modules/$(uname -r)/kernel/net/mac80211/mac80211.ko  debug=0x001FFFFE
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko  debug=0x001FFFFE
    insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko debug=0x001FFFFE
