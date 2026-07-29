#!/bin/sh
#THIS FILE SHOULD BE SET READ-ONLY. DO NOT EDIT CASES OR SPACES TO PREVENT MISFUNCTIONING

EXPECTED_BRAND=SM0000

#case is important because values are treated as strings
STATE_NONE=0xff
STATE_0=0xf0
STATE_1=0xe1
STATE_2=0xd2
STATE_3=0xc3

cd $(dirname $0)
ROOTDIR=$(pwd)

export PATH=$PATH:/bin:/sbin:/usr/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib

pkill psplash
#wait at least 1 sec
sleep 1
psplash &
sleep 1


createLogFile_N()
{
if [[ -e $ROOTDIR ]] ; then
    LOG_FILE=$ROOTDIR/eMMCfwUpdate_$1.log
    #delete old logfile
    if [[ -e $LOG_FILE ]] ; then
        rm $LOG_FILE
    fi
    #create new logfile
    echo "log (flag=$flag) created on $(date)" > $LOG_FILE
fi
}


readFlag()
{
    stringflag="$(dd if=/sys/bus/i2c/devices/0-0054/eeprom skip=151 bs=1 count=1 2>/dev/null | hexdump -e '1/1 "%02x"')"
    #prepend 0x to string value
    flag="0x$stringflag"
	echo "readFlag: *$flag*" >> $LOG_FILE
	sleep 1
}


writeFlag()
{
    arg1=$1

    # busybox's printf requires old POSIX octal escape \0 ; the hex \x is not guaranteed
    # (the %03o is like %02x for hexadecimals till 0xFF)
    printf "\\$(printf '%03o' "$arg1")"  | dd of=/sys/bus/i2c/devices/0-0054/eeprom bs=1 seek=151
}


md5check()
{
	file=$1
    #check if bin file exists 
    if [ ! -e ${ROOTDIR}/$file ] ; then
		psplash-write "MSG ${ROOTDIR}/$file not found"
		echo "${ROOTDIR}/$file not found" >> $LOG_FILE
		sleep 1
        exit 1
    fi

    #check if md5 file exists 
    if [ ! -e ${ROOTDIR}/$file.md5 ] ; then
		psplash-write "MSG ${ROOTDIR}/$file.md5 not found"
		echo "${ROOTDIR}/$file.md5 not found" >> $LOG_FILE
		sleep 1
        exit 1
    fi

    #check if md5 file contains a value
    md5=$(cut -d ' ' -f 1 ${ROOTDIR}/$file.md5)
    if [ ! -n "$md5" ] ; then
		psplash-write "MSG ${ROOTDIR}/$file.md5 file empty or wrong: aborting!"
		echo "${ROOTDIR}/$file.md5 file empty or wrong: aborting!" >> $LOG_FILE
		sleep 1
        exit 1
    fi

    #check if calculated md5 agrees with md5 file
    md5computed=$(md5sum ${ROOTDIR}/$file | cut -d' ' -f1)
	### md5computed=$(     md5sum /mnt/data/DCP00.bin  | cut -d' ' -f1
    if [ ! "$md5computed" == "$md5" ] ; then
		psplash-write "MSG $file file MD5 mismatch"
		echo "$file.bin file MD5 mismatch" >> $LOG_FILE
		sleep 1
        exit 1
    fi

	#log infos
    echo "$file.bin file MD5 is OK" >> $LOG_FILE
}

#===================================
# main
#===================================

readFlag
createLogFile_N $flag

# Check if eMMC is the bugged brand
# use '<' instead of 'cat' (avoid a separate cat process)
BRAND=$(</sys/class/mmc_host/mmc1/mmc1\:0001/name)

if [  "$BRAND" != "$EXPECTED_BRAND" ] ; then
	psplash-write "MSG eMMC $BRAND has no problems"
	echo "eMMC $BRAND has no problems" >> $LOG_FILE
	sleep 1
	exit 0
else
	psplash-write "MSG eMMC brand is $BRAND"
	sleep 1
	echo "eMMC brand is $BRAND"   >> $LOG_FILE
	sleep 1
fi   

# Check md5 of files 
md5check DCP00.bin
md5check DCP02.bin
md5check MLO_ORIG.img
md5check MLO_RC1.img

case "$flag" in
    $STATE_0 | $STATE_1 )
		#error states: restore MLO original

        psplash-write "MSG Recovering from failure..."
		echo "Error ($flag): Recovering from failure"  >> $LOG_FILE

		## MLO ORIG is written to /dev/mmcblk at offset 0x20000 i.e. 1K * 128
		echo 0 > /sys/block/mmcblk1boot1/force_ro
		dd if=${ROOTDIR}/MLO_ORIG.img of=/dev/mmcblk1 bs=1K seek=128 
		
		# restore original flag
		writeFlag $STATE_NONE
        sync
        sleep 1

		psplash-write "MSG FAILED, please reboot"
		echo "Error ($flag): FAILED, restored original" >> $LOG_FILE
		sleep 1
        ;;

    $STATE_2 )
        psplash-write "MSG OK, Restoring system"
		echo "OK ($flag) Restoring system"  >> $LOG_FILE

		## MLO orig is written to /dev/mmcblk at offset 0x20000 i.e. 1K * 128
		echo 0 > /sys/block/mmcblk1boot1/force_ro
		dd if=${ROOTDIR}/MLO_ORIG.img of=/dev/mmcblk1 bs=1K seek=128 
        sync
        sleep 1

        psplash-write "MSG UPDATE NOT NECESSARY: Remove USB and reboot"
        echo "Success ($flag). remove usb and reboot"  >> $LOG_FILE
		sleep 1
        ;;

    $STATE_3 )
        psplash-write "MSG OK, Restoring system"
		echo "OK ($flag) Restoring system"  >> $LOG_FILE

		## MLO orig is written to /dev/mmcblk at offset 0x20000 i.e. 1K * 128
		echo 0 > /sys/block/mmcblk1boot1/force_ro
		dd if=${ROOTDIR}/MLO_ORIG.img of=/dev/mmcblk1 bs=1K seek=128 
        sync
        sleep 1

        psplash-write "MSG SUCCESS: Remove USB and reboot"
        echo "Success ($flag). remove usb and reboot"  >> $LOG_FILE
		sleep 1
        ;;

    *)    
		# INITIAL NO-STATE
		psplash-write "MSG Starting update. wait..."
		echo "(state $flag): Starting update..." >> $LOG_FILE				

		## WRITING FW FILES TO BOOT1 area of eMMC
		echo 0 > /sys/block/mmcblk1boot1/force_ro
		dd if=${ROOTDIR}/DCP00.bin of=/dev/mmcblk1boot1 bs=1K seek=1024
		dd if=${ROOTDIR}/DCP02.bin of=/dev/mmcblk1boot1 bs=1K seek=1044

		## WRITING MLO to /dev/mmcblk at offset 0x20000 (i.e. 1K * 128)
		dd if=${ROOTDIR}/MLO_RC1.img of=/dev/mmcblk1 bs=1K seek=128 

		writeFlag $STATE_0			
        sync
        sleep 2

		psplash-write "MSG Wait Auto-rebooting..."
        echo "new FW files copied. Now auto-rebooting" >> $LOG_FILE
		sleep 2		
		reboot -f
        ;;
esac


