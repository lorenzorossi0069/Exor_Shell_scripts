#!/bin/bash
#
# Load/Unload either CY4373 Azurewave Or (obsolete) Redpine RS9113 kernel modules for wifi
#
#NOTE:
#  wifi drivers could be loaded also without this script because there are other ways, like:
# 1
#  in /lib/modules/$(uname -r)/modules.alias there is a line with VID:PID = 04b4:0bdc, as following:
#  alias usb:v04B4p0BDCd*dc*dsc*dp*ic*isc*ip*in* brcmfmac
#  and this causes a call to modprobe brcmfmac if lsusb detects VID:PID
# 2
#  or EPAD can call command /usr/bin/modem wifion which enable wifi
#
# in any case we left the required insmod command to load wifi drivers depending on found chipset (RSI or AW)

. /etc/default/rcS
. /etc/exorint.funcs

WIFI_SUPPORT=0

# Fastboot runs this script towards the end of rcS - block init invocation
[ "$ENABLE_FASTBOOT" = "yes" ] && [ $PPID -eq 1 ] && exit 0

# Check PLCM10 Module with integrated WIFI
WIFI_PLCM10=0
plcdev="$(modem dev)"
if [ ! -z ${plcdev} -a -e ${plcdev} ]; then
     funcarea="$(dd if=${plcdev}/eeprom skip=37 bs=1 count=1 2>/dev/null | hexdump -e '"%d"')"
     # check plcm eeprom for wifi bit
     if [ $(( ${funcarea} & 128 )) -eq 128 ]; then
         WIFI_PLCM10=1
     fi
fi

#Get specific gpio number for this platform and set WIFI_SUPPORT
if [ -e "/etc/default/wifi_gpio" ]; then
    . /etc/default/wifi_gpio
fi


if [ ${WIFI_PLCM10} -eq 0 ]; then
     [ ${WIFI_SUPPORT} -eq 0 ] && exit 0

     # Check WiFi disable bit in Jumper Flag Area
     [ "$( offsetjumperarea_bit 6 )" -eq 1 ] && [ "$(exorint_ver_carrier)" != "CA16" ] && exit 0

     # Check WiFi disable bit in SW Flag Area
     [ "$( exorint_swflagarea_bit 16 )" -eq 1 ] && exit 0
fi

querychipset()
{
    [ -z "${CYPRESS}" ] && CYPRESS=$(lsusb 2> /dev/null | grep -cie "04b4:0bdc" -cie "04b4:bd29")
    [ -z "${REDPINE}" ] && REDPINE=$(lsusb 2> /dev/null | grep -ci "1618:9113")
    echo "WiFi USB module: CYPRESS=$CYPRESS, REDPINE=$REDPINE" | logger --tag="wifi" | logger --tag="wifi"
}

usbmount()
{
    querychipset
    if [ $CYPRESS -eq 1 ]; then
        echo "Loading Cypress modules" | logger --tag="wifi"
		
        #cfg80211.ko is loaded even if no wifi hw is found, but insmod command is left here  
        # at least as documentation, and because it is required in any case
		
        #Also brcm* modules are loaded even this branch is not executed (see note above)
        # but again they are left here at least as documentation, and because required in any case 

        insmod /lib/modules/$(uname -r)/kernel/net/wireless/cfg80211.ko 
        insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko 
        insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko 

     elif [ $REDPINE -eq 1 ] ; then
        echo "Loading Redpine RS9113 modules" | logger --tag="wifi"
		
        #cfg80211.ko is loaded even if no wifi hw is found, but insmod command is left here  
        # at least as documentation, and because it is required in any case

        insmod /lib/modules/$(uname -r)/kernel/net/wireless/cfg80211.ko
        insmod /lib/modules/$(uname -r)/kernel/net/mac80211/mac80211.ko
        insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi/rsi_91x.ko
        insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/rsi/rsi_usb.ko

        # Antenna int/ext mode is read from SEEPROM 30:0 - currently allocated for CAREL only
        if [ -z $ANTMODE ]; then
            ANTMODE=0 # default to internal antenna

            if [ "$(exorint_ver_carrier)" = "CA16" ]; then
                # Base antenna selection on seeprom byte 30
                "$(exorint_seeprom_byte 30)" = "1" ] && ANTMODE=1
            else
                # Base antenna selection on jumper area bit
                [ "$(offsetjumperarea_bit 5)" = "1" ] && ANTMODE=1
            fi

            # Use external antenna for PLCM
            [ ${WIFI_PLCM10} -eq 1 ] && ANTMODE=1
        fi
        echo "Detected ANTMODE: $ANTMODE (0:internal 1:external)" | logger --tag="wifi"
        iw phy phy0 set antenna ${ANTMODE} ${ANTMODE}
    else
        echo "WiFi USB module NOT FOUND! (nerither RSI nor brcmfmac): anyway it could be found later by EPAD" | logger --tag="wifi"
    fi
}

load()
{
    if [ "$WIFI_GPIO" != "" ]
    then
        if [ ! -d /sys/class/gpio/gpio$WIFI_GPIO/ ]
        then
            echo $WIFI_GPIO > /sys/class/gpio/export
        fi;
        echo out > /sys/class/gpio/gpio$WIFI_GPIO/direction
        echo 1 > /sys/class/gpio/gpio$WIFI_GPIO/value
        #Don't unexport

        # add extra time to board GPIO wifi to wake-up from reset
        # (not critical: in case it will be retried from EPAD, see initial NOTE)
        sleep 3
    fi;
    usbmount
}

unload()
{
    querychipset
    if [ $CYPRESS -eq 1 ]; then
      echo "UN-loading Cypress modules" | logger --tag="wifi"
	  
      rmmod brcmfmac
      rmmod brcmutil
      rmmod cfg80211
    elif [ $REDPINE -eq 1 ] ; then
      echo "UN-loading Redpine RS9113 modules" | logger --tag="wifi"
	  
      rmmod rsi_91x
      rmmod rsi_usb 
      rmmod mac80211
      rmmod cfg80211
    fi

    #wifi reset
    if [ "$WIFI_GPIO" != "" ]
    then
        if [ ! -d /sys/class/gpio/gpio$WIFI_GPIO/ ]
        then
            echo $WIFI_GPIO > /sys/class/gpio/export
        fi;
        echo out > /sys/class/gpio/gpio$WIFI_GPIO/direction
        echo 0 > /sys/class/gpio/gpio$WIFI_GPIO/value
        echo $WIFI_GPIO > /sys/class/gpio/unexport
        usleep 100000
    fi;
}

startPLCM10()
{
    echo "Starting PLCMxx wifi module" | logger --tag="wifi"
    $(modem wifion)

    # add extra time to PLCM10 wifi to wake-up from reset
    # (not critical: in case it will be retried from EPAD, see initial NOTE)
    sleep 3
}

setap()
{
    querychipset
    if [ $CYPRESS -eq 1 ]; then
        local AP="$(sys_params -r -l 'network/wifi/interfaces/1/mode')"
    if [ "${AP}" == "AP" ]; then
           local CHANNEL="$(sys_params -r -l 'network/wifi/interfaces/1/channel')"
        if [ ! -z "${CHANNEL}" ]; then
              echo "Set channel -$CHANNEL- in Cypress" | logger --tag="wifi"
              wl channel ${CHANNEL}
           fi
        fi
    else
        #No cypress chipset, no command needed
        echo "setap skipped"
    fi
}

setcountry()
{
    querychipset
    if [ $CYPRESS -eq 1 ]; then
        local COUNTRY=$(sys_params -r -l locale/country)
        echo "Setting country -$COUNTRY- in Cypress" | logger --tag="wifi"
    if [ ! -z "$COUNTRY" ]; then
       [ "$COUNTRY" == "00" ] && echo "Country reset not handled"
           [ "$COUNTRY" != "00" ] && wl country $COUNTRY
        fi
    else
        #No cypress chipset, no set country command needed
    echo "setcountry skipped"
    fi
}

getcountry ()
{
    querychipset
    if [ $CYPRESS -eq 1 ]; then
        wl country
    fi
}

getchannels()
{
    querychipset
    if [ $CYPRESS -eq 1 ]; then
        # two rows with channels list for selected country
        # 2 4 5 6
        # 2 4 8 10 11 12
        local COUNTRY=$(sys_params -r -l locale/country)
    wl channels_in_country $COUNTRY a
        wl channels_in_country $COUNTRY b
    fi
}

echo "Execute operation $1" | logger --tag="wifi"

case "$1" in
start)
    if [ ${WIFI_PLCM10} -eq 1 ]; then
        startPLCM10
    fi

    load
    setcountry
    setap
    ;;

stop)
    unload
    ;;

force-reload|restart)
    unload
    sleep 1
    load
    setcountry
    setap
    ;;

setcountry)
    setcountry
    ;;

setap)
    setap
    ;;

setcypress)
    setcountry
    setap
    ;;

getchannels)
    getchannels
    ;;

getcountry)
    getcountry
    ;;

usbmount)
    usbmount
    setcountry
    setap
    ;;

esac

