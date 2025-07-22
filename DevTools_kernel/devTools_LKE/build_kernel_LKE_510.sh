#!/bin/bash

trap exit 0 SIGINT

# help message
if [[ $# < 2 ]] ; then
	echo "needs aguments: <arm32/arm64> <defconfig_file>"
	echo "used argument lists are:"
	
	echo "UN60 base)      lke_510::  arm32 am33xxusom_defconfig"
	echo
	
	# iMX6 US03 JSmart700 + eX700/eXware700 with PLCM10 (UN65, SB65)
	# imx6usom_defconfig, imx6usom_secure_defconfig
	# 
	# iMX8 US04 JSmart700M + eX700M/eXware700M with PLCM10 (UN78, SB78)
	# us04_defconfig, us04_secure_defconfig
	# 
	# Sitara US01 eX705/eXware703 (UN60)
	# am33xxusom_defconfig (lke_510, US01 arm32)
	# 
	# STM32 NS02 WE20 i5 + WE22 I7 FL + XA5 (UN83)
	# ns02_fastboot_defconfig (NS02 stm32 arm32; prima serve porting a kernel 5.10)
	# 
	# iMx8 US04 WE20 i10/i12 (UN84)
	# us04_fastboot_defconfig
	# 
	# Sitara US01 WE16 (ignore it, can be conidered obsolete in 2026) (UN67)
	# 
	# Sitara US03 WE16 (ignore it, can be conidered obsolete in 2026) (UN68)
	
	echo "<defconfig_file> are found in arch/arm64/configs or arch/arm/configs"
	echo
        exit 1
fi

armHW=$1
DEFCONFIG_FILE=$2

# save current path and move to kernel source root
targetUpdatePath=$PWD/targetUpdate
cd ..

if [[ $armHW == arm64 ]] ; then
	if [[ ! -e arch/arm64/configs/$DEFCONFIG_FILE ]] ; then
		echo "$DEFCONFIG_FILE not found (in $armHW defconfig folder)" 
		exit 1
	fi
	source /opt/exorintos-2.x.x/2.x.x/environment-setup-aarch64-poky-linux;CFLAGS="";LDFLAGS=""
	make $DEFCONFIG_FILE
	echo "going to build Image"
	#sleep 3
	make Image -j8
elif [[ $armHW == arm32 ]] ; then
	if [[ ! -e arch/arm/configs/$DEFCONFIG_FILE ]] ; then
		echo "$DEFCONFIG_FILE not found (in $armHW defconfig folder)" 
		exit 1
	fi
	source /opt/exorintos-3.x.x/3.x.x/environment-setup-cortexa8hf-neon-poky-linux-gnueabi;CFLAGS="";LDFLAGS=""
	make $DEFCONFIG_FILE
	echo "going to build zImage"
	#sleep 3
	make zImage -j8
else
	echo "Error: found arg value=$armHW: must be arm64 or arm32"
	exit 1
fi

echo "now making modules" 
make modules -j8

echo "now making dtbs"
make dtbs

cd $targetUpdatePath
echo "clean $targetUpdatePath"
[[ -e Image ]] && rm Image
[[ -e zImage ]] && rm zImage
rm *.ko

echo "copy Image and modules in $targetUpdatePath"

cp ../../net/mac80211/mac80211.ko $targetUpdatePath
cp ../../net/wireless/cfg80211.ko $targetUpdatePath
cp ../../drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko $targetUpdatePath
cp ../../drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko $targetUpdatePath
cp ../../drivers/net/wireless/rsi/rsi_91x.ko $targetUpdatePath
cp ../../drivers/net/wireless/rsi/rsi_usb.ko $targetUpdatePath


if [[ $armHW == arm64 ]] ; then
	cp ../../arch/arm64/boot/Image $targetUpdatePath
	
	#cp ../../net/ipv4/netfilter/iptable_filter.ko $targetUpdatePath
	#cp ../../net/ipv4/netfilter/ip_tables.ko      $targetUpdatePath
	#cp ../../net/netfilter/x_tables.ko            $targetUpdatePath
	#cp ../../drivers/crypto/caam/fsl_jr_uio.ko     $targetUpdatePath
	
elif [[ $armHW == arm32 ]] ; then
	cp ../../arch/arm/boot/zImage $targetUpdatePath
	
	#cp ../../net/ipv4/netfilter/iptable_filter.ko $targetUpdatePath 
	#cp ../../net/ipv4/netfilter/ip_tables.ko $targetUpdatePath
	#cp ../../net/netfilter/x_tables.ko $targetUpdatePath
	#cp ../../crypto/sha256_generic.ko $targetUpdatePath
	#cp ../../lib/crypto/libsha256.ko  $targetUpdatePath
	#cp ../../drivers/misc/nxp-pn5xx/pn5xx_i2c.ko  $targetUpdatePath
	
	if [[ $DEFCONFIG_FILE =~ "am33xxusom_" ]] ; then
		echo "copying files for $DEFCONFIG_FILE"

		cp ../../net/ipv4/netfilter/iptable_filter.ko $targetUpdatePath
		cp ../../net/ipv4/netfilter/ip_tables.ko  $targetUpdatePath
		cp ../../net/netfilter/x_tables.ko $targetUpdatePath
		cp ../../crypto/sha256_generic.ko $targetUpdatePath
		cp ../../lib/crypto/libsha256.ko $targetUpdatePath
		cp ../../net/wireless/cfg80211.ko $targetUpdatePath
		cp ../../fs/ext2/ext2.ko $targetUpdatePath	
		cp ../../drivers/crypto/omap-aes-driver.ko $targetUpdatePath
		cp ../../drivers/crypto/omap-crypto.ko $targetUpdatePath
		cp ../../drivers/crypto/omap-sham.ko $targetUpdatePath
		cp ../../crypto/crypto_engine.ko $targetUpdatePath
		cp ../../drivers/char/hw_random/omap-rng.ko $targetUpdatePath
		cp ../../drivers/char/hw_random/rng-core.ko $targetUpdatePath
		
	fi
fi

