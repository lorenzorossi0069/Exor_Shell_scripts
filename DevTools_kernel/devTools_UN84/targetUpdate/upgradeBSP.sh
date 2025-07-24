#!/bin/sh

if [[ $# < 1 ]] ; then
		echo "Error:"
		echo "arguments: < UN78 | UN65 | UN96 | UN60 | UN83 | UN84 >"
		exit 1
fi

source ./upgradeFunctions.sh 

BSP_NAME=$1

SETUPDIR=$PWD

mount -o remount,rw /

rename_modules_folder K5
if [[ $? != 0 ]] ; then
	echo "Error renaming folder"
	echo "---------------------"
	exit 1
fi

echo "create (hierarchy of) unexisting folders"

createUnexistingFolder /lib/firmware/cypress
#createUnexistingFolder /lib/modules/$(uname -r)/kernel/net/mac80211
createUnexistingFolder /lib/modules/$(uname -r)/kernel/drivers/net/wireless
createUnexistingFolder /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac


# SYNTAX INFO: copyFileToTaget function requires the following 4 arguments:
#  <source_directory>  :it is this directory $SETUPDIR, because files to be copied are all here (if not, change $SETUPDIR  with source path)
#  <source_filename.ko> : it is the name of source file, as found in source path (it can be renamed)
#  <destination directory> : it is the path on target
#  <destination_filename.ko> : it is the name of file (can be renamed) on target

copyFileToTaget $SETUPDIR cfg80211.ko  /lib/modules/$(uname -r)/kernel/net/wireless  						cfg80211.ko	
copyFileToTaget $SETUPDIR brcmutil.ko  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil 	brcmutil.ko
copyFileToTaget $SETUPDIR brcmfmac.ko  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac 	brcmfmac.ko
copyFileToTaget $SETUPDIR mac80211.ko  /lib/modules/$(uname -r)/kernel/net/mac80211  						mac80211.ko
#Community driver for RSI
copyFileToTaget $SETUPDIR rsi_91x.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_91x.ko
copyFileToTaget $SETUPDIR rsi_usb.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_usb.ko

#needed modules as found launching original BSP
if [[ $BSP_NAME == UN84 ]] ; then
	#not known without testing HW	
fi

if [[ $BSP_NAME == UN83 ]] ; then	
	copyFileToTaget $SETUPDIR dwc2.ko 	/lib/modules/$(uname -r)/kernel/drivers/usb/dwc2        dwc2.ko
	copyFileToTaget $SETUPDIR udc-core.ko 	/lib/modules/$(uname -r)/kernel/drivers/usb/gadget/udc  udc-core.ko
	copyFileToTaget $SETUPDIR spidev.ko 	/lib/modules/$(uname -r)/kernel/drivers/spi		spidev.ko
	copyFileToTaget $SETUPDIR smsc95xx.ko 	/lib/modules/$(uname -r)/kernel/drivers/net/usb		smsc95xx.ko
	copyFileToTaget $SETUPDIR usbnet.ko 	/lib/modules/$(uname -r)/kernel/drivers/net/usb		usbnet.ko
	copyFileToTaget $SETUPDIR stm32-timer-trigger.ko /lib/modules/$(uname -r)/kernel/drivers/iio/trigger stm32-timer-trigger.ko
fi


#copy firmware
copyFileToTaget  $SETUPDIR cyfmac4373.bin         /lib/firmware/cypress cyfmac4373.bin
copyFileToTaget  $SETUPDIR cyfmac4373.clm_blob    /lib/firmware/cypress cyfmac4373.clm_blob

if [[ $BSP_NAME == UN84 ]] then
	#arm64
	copyFileToTaget $SETUPDIR wlfmac1.28_arm64	 /usr/sbin  wl
	#copyFileToTaget  $SETUPDIR wifi_gpio            /etc/default wifi_gpio  #check if needed
	copyFileToTaget networking_rs911xcy4373.sh	/etc/init.d networking_rs911xcy4373.sh
	echo "create symlink"
	ln -s networking-wifi networking_rs911xcy4373.sh

elif [[ $BSP_NAME == UN83 ]] ; then
	#arm32
	copyFileToTaget $SETUPDIR wlfmac1.28_arm	 /usr/sbin  wl	
	#copyFileToTaget  $SETUPDIR wifi_gpio            /etc/default wifi_gpio  #check if needed
	copyFileToTaget networking_rs911xcy4373.sh	/etc/init.d networking_rs911xcy4373.sh
	echo "create symlink"
	ln -s networking-wifi networking_rs911xcy4373.sh
fi

sync

echo -n  " enter any key to reboot "; read dummy
reboot


