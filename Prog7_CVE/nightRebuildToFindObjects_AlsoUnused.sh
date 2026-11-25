#!/bin/bash

# RAW script to rebuild all

buildAllAndLogErrors () {

	test_invalid_command_1
	
	#1
	echo "build for imx arm64" >&2
	cd /home/me/WS/CVE/imx6linux
	source /opt/exorintos-2.x.x/2.x.x/environment-setup-aarch64-poky-linux;CFLAGS="";LDFLAGS=""
	for defcfg in $(ls arch/arm64/configs/ | grep "_defconfig") ; do echo "using $defcfg" >&2  ; make $defcfg ; make Image -j8; make modules -j8 ;  done 
	
	#2
	echo "build for imx arm32" >&2
	cd /home/me/WS/CVE/imx6linux
	source /opt/exorintos-3.x.x/3.x.x/environment-setup-cortexa8hf-neon-poky-linux-gnueabi;CFLAGS="";LDFLAGS=""
	for defcfg in $(ls arch/arm/configs/ | grep "_defconfig") ; do echo "using $defcfg" >&2 ; make $defcfg ; make zImage -j8; make modules -j8 ;  done 
	
	#3 
	echo "build for TI (lke) arm32" >&2
	cd /home/me/WS/CVE/lke
	source /opt/exorintos-3.x.x/3.x.x/environment-setup-cortexa8hf-neon-poky-linux-gnueabi;CFLAGS="";LDFLAGS=""
	for defcfg in $(ls arch/arm/configs/ | grep "_defconfig") ; do echo "using $defcfg" >&2 ; make $defcfg ; make zImage -j8; make modules -j8 ;  done 
	
	#4 
	echo "build for stm32 arm32" >&2
	cd /home/me/WS/CVE/stm32_linux
	source /opt/exorintos-3.x.x/3.x.x/environment-setup-cortexa8hf-neon-poky-linux-gnueabi;CFLAGS="";LDFLAGS=""
	for defcfg in $(ls arch/arm/configs/ | grep "_defconfig") ; do echo "using $defcfg" >&2 ; make $defcfg ; make zImage -j8; make modules -j8 ;  done 
}

if [[ $# < 1 ]] ; then
	echo "needs filename (automatically saved in upper folder)"
	exit 1
else
	filename=$1
	buildAllAndLogErrors 2> $1
fi

