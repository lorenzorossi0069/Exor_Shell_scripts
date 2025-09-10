#!/bin/bash

trap exit 0 SIGINT

TARGET_IP=10.1.35.22
BASE_S_IP=10.1.35.22

DEV_TOOLS_DIR=$PWD
NEW_IMAGE_AND_MODULES=$DEV_TOOLS_DIR/newImageAndModules


if [[ $# < 1 ]] ; then
	echo "needs aguments: <arm32/arm64> <defconfig_file>"
	echo "used argument lists are:"
	
	echo "1= UN89 AX210 Intel)		arm64 us04_xsafety_defconfig"
        echo "2= UN89 AX210 Intel EMC)     arm64 us04_xsafety_EMC_Testing_defconfig"
        echo "3= UN89 AX210 MagicSysRq)    arm64 us04_xsafety_MAGIC_SYSRQ_defconfig"

	echo
	
	echo "<defconfig_file> are found in arch/arm64/configs or arch/arm/configs"
	echo
        exit 1
fi

case $1 in
	( 1 )
	armHW=arm64
	DEFCONFIG_FILE=us04_xsafety_defconfig ;;
	( 2 )
	armHW=arm64
	DEFCONFIG_FILE=us04_xsafety_EMC_Testing_defconfig ;;
	( 3 )
	armHW=arm64
	DEFCONFIG_FILE=us04_xsafety_MAGIC_SYSRQ_defconfig ;;
esac
	
[[ -e $NEW_IMAGE_AND_MODULES ]] && echo "delete old stuff" && rm -rf $NEW_IMAGE_AND_MODULES 
echo "create new $NEW_IMAGE_AND_MODULES"
mkdir $NEW_IMAGE_AND_MODULES

# move to kernel source root
cd ..

if [[ $armHW == arm64 ]] ; then
	if [[ ! -e arch/arm64/configs/$DEFCONFIG_FILE ]] ; then
		echo "$DEFCONFIG_FILE not found (in $armHW defconfig folder)" 
		exit 1
	fi
	source /opt/exorintos-2.x.x/2.x.x/environment-setup-aarch64-poky-linux;CFLAGS="";LDFLAGS=""
	make $DEFCONFIG_FILE
	echo "going to build Image"
	make Image -j8
elif [[ $armHW == arm32 ]] ; then
	if [[ ! -e arch/arm/configs/$DEFCONFIG_FILE ]] ; then
		echo "$DEFCONFIG_FILE not found (in $armHW defconfig folder)" 
		exit 1
	fi
	source /opt/exorintos-3.x.x/3.x.x/environment-setup-cortexa8hf-neon-poky-linux-gnueabi;CFLAGS="";LDFLAGS=""
	make $DEFCONFIG_FILE
	echo "going to build zImage"
	make zImage -j8
else
	echo "Error: found arg value=$armHW: must write arm64 or arm32"
	exit 1
fi

echo "now making modules" 
make modules -j8

echo "now making dtbs"
make dtbs

echo "copy all to $NEW_IMAGE_AND_MODULES"

cp $DEV_TOOLS_DIR/targetUpdate_devMaster.sh $NEW_IMAGE_AND_MODULES/targetUpdate_replicated.sh

cp arch/arm64/boot/Image $NEW_IMAGE_AND_MODULES

echo "prepare new modules target tree in $NEW_IMAGE_AND_MODULES"
make modules_install INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$NEW_IMAGE_AND_MODULES

echo "preparing tar.gz"

cd $NEW_IMAGE_AND_MODULES/lib/modules

tar -czvf newModules.gz .

mv newModules.gz ../../.

cd $NEW_IMAGE_AND_MODULES


echo "check untar"; read dummy
rm -rf lib
echo "check cleared"; read dummy

echo "secure-copying whole $NEW_IMAGE_AND_MODULES to $TARGET_IP"
sshpass -p "Exor123@" scp -r $NEW_IMAGE_AND_MODULES admin@$TARGET_IP:/mnt/data


