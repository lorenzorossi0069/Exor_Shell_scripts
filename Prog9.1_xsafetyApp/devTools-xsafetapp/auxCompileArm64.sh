#!/bin/bash

BASE_STATION_IP=10.1.35.20
TERMINAL_IP=10.1.35.22

trap exit 0 SIGINT

#fixed arm64 arch
armHW=arm64

if [[ $armHW == arm64 ]] ; then
	source /opt/exorintos-2.x.x/2.x.x/environment-setup-aarch64-poky-linux;CFLAGS="";LDFLAGS=""

#elif [[ $armHW == arm32 ]] ; then
#	source /opt/exorintos-3.x.x/3.x.x/environment-setup-cortexa8hf-neon-poky-linux-gnueabi;CFLAGS="";LDFLAGS=""

else
	echo "Error: found arg value=$armHW: must be arm64 or arm32"
	exit 1
fi
#create folders for binaries build
mkdir ../bin_bs
mkdir ../bin_t

#save current path and move to source root path and launch T and BS builders
DEV_TOOLS_DIR=$PWD
cd ..
./compile_term.sh
./compile_bs.sh

echo "press ENTER to do scp of files to targets (or ctrl-c to exit)" ; read doNotSkip
#----------------------------------------------------------
echo "1) scp-ing safety_app_* to terminal"
sshpass -p "Exor123@"             scp bin_bs/safety_app_B  admin@$TERMINAL_IP:/mnt/data/
sshpass -p "Exor123@"             scp bin_t/safety_app_T  admin@$TERMINAL_IP:/mnt/data/

echo "2) scp-ing pairingTestApp to terminal (Edit Terminal's IP address is not $TERMINAL_IP)"
#to avoid inserting password, use sshpass
sshpass -p "Exor123@"             scp bin_t/pairingTestApp admin@$TERMINAL_IP:/mnt/data

echo "3) scp-ing unpairingTestApp to terminal (Edit Terminal's IP address is not $TERMINAL_IP)"
#to avoid inserting password, use sshpass
sshpass -p "Exor123@"             scp bin_t/unpairingTestApp admin@$TERMINAL_IP:/mnt/data

echo "4) scp-ing preparexTest_T.sh to T target"
sshpass -p "Exor123@"            scp $DEV_TOOLS_DIR/preparexTest_T.sh admin@$TERMINAL_IP:/mnt/data/
#-----------------------
echo "5) scp-ing safety_app_* to BaseStation"
sshpass -p "Exor123@"            scp bin_bs/safety_app_B admin@$BASE_STATION_IP:/mnt/data/
sshpass -p "Exor123@"            scp bin_t/safety_app_T admin@$BASE_STATION_IP:/mnt/data/

echo "6) scp-ing preparexBsTest.sh to BS target"
sshpass -p "Exor123@"            scp $DEV_TOOLS_DIR/preparexBsTest.sh admin@$BASE_STATION_IP:/mnt/data/


echo "------------------------------------------------------------"
echo "remember to move files to rigth path in T and BS targets"
echo "(launch preparexTest_T.sh on terminal and preparexBsTest.sh on BasStation)"
echo "------------------------------------------------------------"





