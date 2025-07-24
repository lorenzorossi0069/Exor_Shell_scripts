#!/bin/sh

echo "inserting manually kernel modules for UN83WU20"
cd /lib/modules/$(uname -r)
insmod kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko
insmod kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
