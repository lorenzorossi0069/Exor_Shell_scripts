#!/bin/sh

if [[ $# < 1 ]] ; then
		echo "Error:"
		echo "arguments: < UN78 | UN65 | UN96 | UN60 >"
		exit 1
fi

source ./upgradeFunctions.sh 

BSP_NAME=$1

SETUPDIR=$PWD

mount -o remount,rw /

#rename /lib/modules/$(uname -r)
rename_modules_folder K5
if [[ $? != 0 ]] ; then
	echo "Error renaming folder"
	echo "---------------------"
	exit 1
fi

echo "create (hierarchy of) unexisting folders"

#createUnexistingFolder /lib/firmware/cypress
#createUnexistingFolder /lib/modules/$(uname -r)/kernel/net/mac80211
createUnexistingFolder /lib/modules/$(uname -r)/kernel/drivers/net/wireless
createUnexistingFolder /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil
createUnexistingFolder  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac

echo "updating files for kernel $Kvers"

# SYNTAX INFO: copyFileToTaget function requires the following 4 arguments:
#  <source_directory>  :it is this directory $SETUPDIR, because files to be copied are all here (if not, change $SETUPDIR  with source path)
#  <source_filename.ko> : it is the name of source file, as found in source path (it can be renamed)
#  <destination directory> : it is the path on target
#  <destination_filename.ko> : it is the name of file (can be renamed) on target

copyFileToTaget $SETUPDIR cfg80211.ko  /lib/modules/$(uname -r)/kernel/net/wireless  						cfg80211.ko	
copyFileToTaget $SETUPDIR brcmutil.ko  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil 	brcmutil.ko
copyFileToTaget $SETUPDIR brcmfmac.ko  /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac 	brcmfmac.ko
	
copyFileToTaget $SETUPDIR mac80211.ko  /lib/modules/$(uname -r)/kernel/net/mac80211  						mac80211.ko
	
if [[ $BSP_NAME == UN78 ]] ; then
	#Community driver for RSI 
	copyFileToTaget $SETUPDIR rsi_91x.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_91x.ko
	copyFileToTaget $SETUPDIR rsi_usb.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_usb.ko
	copyFileToTaget $SETUPDIR iptable_filter.ko /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	iptable_filter.ko
	copyFileToTaget $SETUPDIR ip_tables.ko    	/lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	ip_tables.ko
	copyFileToTaget $SETUPDIR x_tables.ko       /lib/modules/$(uname -r)/kernel/net/netfilter        	x_tables.ko
	copyFileToTaget $SETUPDIR fsl_jr_uio.ko     /lib/modules/$(uname -r)/kernel/drivers/crypto/caam  	sl_jr_uio.ko

fi

if [[ $BSP_NAME == UN65 ]] ; then
	#Community driver for RSI 
	copyFileToTaget $SETUPDIR rsi_91x.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_91x.ko
	copyFileToTaget $SETUPDIR rsi_usb.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_usb.ko
	copyFileToTaget $SETUPDIR iptable_filter.ko  /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	iptable_filter.ko
	copyFileToTaget $SETUPDIR ip_tables.ko       /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	ip_tables.ko
	copyFileToTaget $SETUPDIR x_tables.ko        /lib/modules/$(uname -r)/kernel/net/netfilter        	x_tables.ko
	copyFileToTaget $SETUPDIR sha256_generic.ko  /lib/modules/$(uname -r)/kernel/crypto               	sha256_generic.ko
	copyFileToTaget $SETUPDIR libsha256.ko       /lib/modules/$(uname -r)/kernel/lib/crypto           	libsha256.ko
	copyFileToTaget $SETUPDIR pn5xx_i2c.ko       /lib/modules/$(uname -r)/kernel/drivers/misc/nxp-pn5xx	pn5xx_i2c.ko
fi

if [[ $BSP_NAME == UN60 ]] ; then
	#Community driver for RSI 
	copyFileToTaget $SETUPDIR rsi_91x.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_91x.ko
	copyFileToTaget $SETUPDIR rsi_usb.ko   /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi 	rsi_usb.ko
	
	copyFileToTaget $SETUPDIR iptable_filter.ko  /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	iptable_filter.ko
	copyFileToTaget $SETUPDIR ip_tables.ko       /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	ip_tables.ko
	copyFileToTaget $SETUPDIR x_tables.ko        /lib/modules/$(uname -r)/kernel/net/netfilter        	x_tables.ko
	copyFileToTaget $SETUPDIR sha256_generic.ko  /lib/modules/$(uname -r)/kernel/crypto               	sha256_generic.ko
	copyFileToTaget $SETUPDIR libsha256.ko       /lib/modules/$(uname -r)/kernel/lib/crypto           	libsha256.ko
	
	copyFileToTaget $SETUPDIR ext2.ko 	     /lib/modules/$(uname -r)/kernel/fs/ext2			ext2.ko
	copyFileToTaget $SETUPDIR omap-aes-driver.ko /lib/modules/$(uname -r)/kernel/drivers/crypto		omap-aes-driver.ko
	copyFileToTaget $SETUPDIR omap-crypto.ko     /lib/modules/$(uname -r)/kernel/drivers/crypto		omap-crypto.ko
	copyFileToTaget $SETUPDIR omap-sham.ko 	     /lib/modules/$(uname -r)/kernel/drivers/crypto		omap-sham.ko
	copyFileToTaget $SETUPDIR crypto_engine.ko   /lib/modules/$(uname -r)/kernel/crypto			crypto_engine.ko
	copyFileToTaget $SETUPDIR omap-rng.ko 	     /lib/modules/$(uname -r)/kernel/drivers/char		hw_random/omap-rng.ko
	copyFileToTaget $SETUPDIR rng-core.ko 	     /lib/modules/$(uname -r)/kernel/drivers/char		hw_random/rng-core.ko
	
	
	
	
	

fi
	
if [[ $BSP_NAME == UN96 ]] ; then
	copyFileToTaget $SETUPDIR iptable_filter.ko  /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	iptable_filter.ko
	copyFileToTaget $SETUPDIR ip_tables.ko       /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter   	ip_tables.ko
	copyFileToTaget $SETUPDIR x_tables.ko        /lib/modules/$(uname -r)/kernel/net/netfilter        	x_tables.ko
	copyFileToTaget $SETUPDIR sha256_generic.ko  /lib/modules/$(uname -r)/kernel/crypto               	sha256_generic.ko
	copyFileToTaget $SETUPDIR libsha256.ko       /lib/modules/$(uname -r)/kernel/lib/crypto           	libsha256.ko
	# script to initialize wifi module on plugin boards other than CPU (proof-of-concept !!!!!!!!!!!!!!!!)
	#copyFileToTaget $SETUPDIR enable_AW_UN96.sh  /home/admin	                                        enable_AW_UN96.sh
fi
	

#copy firmware
#copyFileToTaget  $SETUPDIR cyfmac4373.bin         /lib/firmware/cypress cyfmac4373.bin
#copyFileToTaget  $SETUPDIR cyfmac4373.clm_blob    /lib/firmware/cypress cyfmac4373.clm_blob

#copyFileToTaget  $SETUPDIR cyfmac4373.bin_REL2         /lib/firmware/brcm brcmfmac4373.bin
#copyFileToTaget  $SETUPDIR cyfmac4373.clm_blob_REL2    /lib/firmware/brcm brcmfmac4373.clm_blob

#if [[ $BSP_NAME == UN78 ]] ; then
#	copyFileToTaget $SETUPDIR wlfmac1.28_arm64	 /usr/sbin  wl
#	copyFileToTaget  $SETUPDIR wifi_gpio               /etc/default wifi_gpio
#elif [[ $BSP_NAME == UN65 ]] ; then
#	copyFileToTaget $SETUPDIR wlfmac1.28_arm	 /usr/sbin  wl
#	copyFileToTaget  $SETUPDIR wifi_gpio               /etc/default wifi_gpio
#elif [[ $BSP_NAME == UN96 ]] ; then
#	copyFileToTaget $SETUPDIR wlfmac1.28_arm	 /usr/sbin  wl	
#	#INFO: for UN96 there is NO wifi_gpio
#fi


sync

echo -n  " enter any key to reboot "; read dummy
reboot


