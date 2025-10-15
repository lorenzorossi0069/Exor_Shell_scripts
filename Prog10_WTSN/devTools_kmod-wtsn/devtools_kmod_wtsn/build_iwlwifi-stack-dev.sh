#!/bin/bash

trap exit 0 SIGINT

TERMINAL_IP=10.1.35.22
BASE_S_IP=10.1.35.20

#arg1 is mandatory, arg2 is oprtional
if [[ $# < 1 ]] ; then
	echo "needs at least kernel fullpath as arg1"
	echo "here some (used) examples: choose your situation:"
	
	echo "$0 /home/me/WS/imx6linux [clean]"
	echo "$0 /home/me/WS/imx6linux-wtsn [clean]"
	echo	
        exit 1
fi


###cd ..
DEV_TOOLS_DIR=$PWD

armHW=arm64
KHEADERS=$1
INSTALL_MOD_PATH=$DEV_TOOLS_DIR/bin_WtsnModules

[[ -e $INSTALL_MOD_PATH ]] && echo "delete old stuff" && rm -rf $INSTALL_MOD_PATH 
echo "create new $INSTALL_MOD_PATH"
mkdir $INSTALL_MOD_PATH

#move to kmod source dir
cd ../iwlwifi-stack-dev

if [[ $armHW == arm64 ]] ; then
	source /opt/exorintos-2.x.x/2.x.x/environment-setup-aarch64-poky-linux;CFLAGS="";LDFLAGS=""
else
	echo "Error: found arg value=$armHW: must write arm64 (arm32 not foreseen now)"
	exit 1
fi

#print informations
#echo "start building OutOfTree kmod"
#echo "pwd=$PWD"
#echo "arch=$ARCH"
echo "script: KHEADERS=$KHEADERS" 
echo "script: INSTALL_MOD_PATH=$INSTALL_MOD_PATH" 

[[ $2 == clean ]] && ( make KHEADERS=$KHEADERS  INSTALL_MOD_PATH=$INSTALL_MOD_PATH clean )

make KHEADERS=$KHEADERS  INSTALL_MOD_PATH=$INSTALL_MOD_PATH -j$(nproc)

find . -name "*.ko" -print0 | xargs -0 aarch64-poky-linux-strip --strip-unneeded 
find . -name "*.ko" -print0 | xargs -0 aarch64-poky-linux-strip --strip-debug

echo "now modules_install"

# note: DEPMOD=/bin/true in command below disables depmod warnings (call it on target side)
#make KHEADERS=$KHEADERS INSTALL_MOD_PATH=$INSTALL_MOD_PATH DEPMOD=/bin/true modules_install
#make V=1 KHEADERS=$KHEADERS INSTALL_MOD_PATH=$INSTALL_MOD_PATH DEPMOD=/bin/true modules_install
make KHEADERS=$KHEADERS INSTALL_MOD_PATH=$INSTALL_MOD_PATH  DEPMOD=/bin/true modules_install


#---------------
#echo "preparing additional kmod_tar.gz"
#cd $INSTALL_MOD_PATH/lib/modules
#tar -czvf kmodModules.gz .
#mv kmodModules.gz $INSTALL_MOD_PATH


echo "press ENTER to scp kmod files to $TERMINAL_IP and $BASE_S_IP"
echo "     (or press Ctrl-C to avoid final scp phase)"
read continueWithScp 

cd $INSTALL_MOD_PATH

sshpass -p "Exor123@" scp -r $INSTALL_MOD_PATH/lib/modules/5.10.*/*/ admin@$TERMINAL_IP:/mnt/data/updatesKmod
sshpass -p "Exor123@" scp -r $INSTALL_MOD_PATH/lib/modules/5.10.*/*/ admin@$BASE_S_IP:/mnt/data/updatesKmod

sshpass -p "Exor123@" scp    $DEV_TOOLS_DIR/kmodUpdate_devMaster.sh admin@$TERMINAL_IP:/mnt/data/kmodUpdate_copy.sh
sshpass -p "Exor123@" scp    $DEV_TOOLS_DIR/kmodUpdate_devMaster.sh admin@$BASE_S_IP:/mnt/data/kmodUpdate_copy.sh

#move to fw-binaries dir
cd $DEV_TOOLS_DIR
cd ..
#copy FW to BaseStation
sshpass -p "Exor123@" scp    fw-binaries/iwlwifi-ty-a0-gf-a0-89.ucode  admin@$BASE_S_IP:/mnt/data/
sshpass -p "Exor123@" scp    fw-binaries/iwlwifi-ty-a0-gf-a0.pnvm  admin@$BASE_S_IP:/mnt/data/
#mockup, needed only for AP
sshpass -p "Exor123@" scp    fw-binaries/iwlwifi-platform.dat admin@$BASE_S_IP:/mnt/data/

#copy FW to Client
sshpass -p "Exor123@" scp    fw-binaries/iwlwifi-ty-a0-gf-a0-89.ucode  admin@$TERMINAL_IP:/mnt/data/
sshpass -p "Exor123@" scp    fw-binaries/iwlwifi-ty-a0-gf-a0.pnvm  admin@$TERMINAL_IP:/mnt/data/

echo 'on target, remember to run depmod -a $(uname -r)'




