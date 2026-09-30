#!/bin/bash

trap exit 0 SIGINT

TARGET_IP=10.1.35.125
#BASE_S_IP=10.1.35.20

DEV_TOOLS_DIR=$PWD
NEW_IMAGE_AND_MODULES=$DEV_TOOLS_DIR/newImageAndModules
armHW=arm64

# move to kernel source root
cd ..

if [[ $armHW == arm64 ]] ; then
   echo "sourcing for ARM64"
   source /opt/exorintos-2.x.x/2.x.x/environment-setup-aarch64-poky-linux;CFLAGS="";LDFLAGS=""


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

rm -rf lib

echo "press ENTER to scp to $TARGET_IP and $BASE_S_IP"
echo "     (or press Ctrl-C to avoid final scp phase)"
read continueWithScp

echo "secure-copying whole $NEW_IMAGE_AND_MODULES to $BASE_S_IP and  $TARGET_IP"
sshpass -p "Exor123@" scp -r $NEW_IMAGE_AND_MODULES admin@$TARGET_IP:/mnt/data
#scp -r $NEW_IMAGE_AND_MODULES admin@$TARGET_IP:/mnt/data

#sshpass -p "Exor123@" scp -r $NEW_IMAGE_AND_MODULES admin@$BASE_S_IP:/mnt/data


