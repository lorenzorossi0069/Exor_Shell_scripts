#!/bin/sh
#
# PLEASE DO NOT MODIFY THIS FILE IN ANY WAY
# Using this script after doing so may cause damage to the device
#

VERSION="2.52"

export PATH=$PATH:/bin/:/sbin/:/usr/bin/:/usr/sbin/:

cd $(dirname $0)
export USBDIR=$(pwd)
export UPDATEFS="/mnt/updatefs"

die()
{
	sleep 1

	echo $1
	sync

	umount "$UPDATEFS"
	/etc/init.d/dbus-1 restart

	psplash-write  "MSG ERROR STARTING USB UPDATER!!!
$1
Unplug the USB stick and reboot the device
"

	psplash-write "PROGRESS 100"

	# If there's no error led use the status led again
	[ -z "$ERROR_LED" ] && ERROR_LED="$STATUS_LED"

	if [ -n "$STATUS_LED" ]; then
		# KO. Status led OFF
		echo none > "${STATUS_LED}/trigger"
		echo 0 > "${STATUS_LED}/brightness"
	fi

	if [ -n "$ERROR_LED" ]; then
		# KO. Error led slow blinking. 1000/500 ms
		echo timer > "${ERROR_LED}/trigger"
		echo 1000 > "${ERROR_LED}/delay_on"
		echo 500 > "${ERROR_LED}/delay_off"
	fi

	echo 0 > $( echo /sys/class/leds/*:dl:usr0/brightness );

	# quit usb context and kill parent to allow eject while continuing to run
	cd /tmp
	(
		removeUSB

		while [ "1" ]; do
			dbus-send --system --print-reply --dest=com.exor.EPAD "/Buzzer" com.exor.EPAD.Buzzer.beep int32:440 int32:100 &>/dev/null; sleep 1;
			echo 0 > $( echo /sys/class/leds/*:fault:usr0/brightness ); sleep 1;
			echo 1 > $( echo /sys/class/leds/*:fault:usr0/brightness ); sleep 1;
		done
        ) &

	exit -1
}

# Notes:
#  - 1.0 has lsof, 1.3 has fuser
removeUSB()
{
	# Close the log file
	exec &>/dev/null
	sync

	USBDRIVE="$( df -h $USBDIR | sed -n 2p | awk '{ print $1 }' )"

	if command -v fuser &>/dev/null; then
		pids=$( fuser -m $USBDIR )
	else
		pids=$( lsof $USBDRIVE | sed 1d | awk '{ print $2 }' )
	fi

	for pid in $pids; do
		[ $pid -eq $$ ] && continue
		kill $pid
	done

	sleep 1

	eject $USBDRIVE
	if [ $? -ne 0 ]; then
		# Try again one more time
		sleep 3
		eject $USBDRIVE
	fi
}

# Skip execution once
if [ -e USBNoExec ]; then
	rm USBNoExec
	sync
	exit 0
fi

[ -e "src/config" ] && . src/config
[ "$CFG_TRACE" == "1" ] && set -x
exec &> lastupdate.log

rotation=0
[ -e /etc/rotation ] && read rotation < /etc/rotation

BSP_VERSION="$( cat /boot/version 2>/dev/null )"

# wait for Window manager (blind panels still have xvfb)
while [ ! -e /tmp/.X11-unix/X0 -a ! -e /tmp/runtime-root/wayland-0 ]; do
	sleep 1;
done

if [ -e /tmp/.X11-unix/X0 ]; then
	# X11
	export DISPLAY=:0
	export QT_IM_MODULE=dbusvirtualkeyboard
	export QT_QPA_PLATFORM=xcb
else
	# Wayland
	export XDG_RUNTIME_DIR=/tmp/runtime-root
	export QT_QPA_PLATFORM=wayland
	export XDG_SESSION_TYPE=wayland
fi

# use xsplash if available, but not on 1.0.x BSPs (outdated)
if [ -x /usr/bin/xsplash -a "${BSP_VERSION:9:5}" != "01000" ]; then
	killall xsplash
	xsplash --no-taptap --no-progress-bar &>/dev/null &
else
	sleep 1
	killall -9 psplash
	psplash --notouch --infinite-progress --angle $rotation &>/dev/null &
fi

HWCODE=$( cat /proc/cmdline | sed 's:.*hw_code=\([0-9]*\).*:\1:' )

case $HWCODE in
128)
	STATUS_LED="/sys/class/leds/na16:led:enable"
	;;
132)
	STATUS_LED="/sys/class/leds/usr"
	;;
158|160)
	STATUS_LED="/sys/class/leds/G"
	ERROR_LED="/sys/class/leds/R"

	echo none > "/sys/class/leds/B/trigger"
	echo 0 > "/sys/class/leds/B/brightness"
	;;
esac

if [ -n "$ERROR_LED" ]; then
	# Error led OFF
	echo none > "${ERROR_LED}/trigger"
	echo 0 > "${ERROR_LED}/brightness"
fi

if [ -n "$STATUS_LED" ]; then
	# Running. Status led fast blinking. 100/100 ms
	echo timer > "${STATUS_LED}/trigger"
	echo 100 > "${STATUS_LED}/delay_on"
	echo 100 > "${STATUS_LED}/delay_off"
fi

[ -e "src/backup" ] && CFG_ENABLE_BACKUP=1
[ "$CFG_ENABLE_BACKUP" == "1" -a "$( df -k . | sed -n 2p | awk '{ print $4 }' )" -lt $(( 1024 * 300 )) ] && die "Backup requires at least 300MB free space"

if [ -n "$CFG_ALLOWED_HWCODES" ]; then

	echo "Checking HW CODE. Compatible codes are: $HWCODES"

	echo "Hw code found: $HWCODE"

	for code in $HWCODES ; do
		[ "$code" = "$HWCODE" ] && codeCheckOK=1
	done
	[ -z "$codeCheckOK" ] && die "Uncompatible platform detected"
fi

OSTYPE=mainos
if [ "${BSP_VERSION:8:1}" == "M" ]; then
	OSTYPE=mainos
else
	OSTYPE=configos
fi

echo "Detected $OSTYPE os"

if [ "$OSTYPE" == "mainos" -a "$CFG_ALLOW_MAINOS_UPDATE" != "1" ] ; then

	psplash-write "MSG Initializing USBUpdater
Reboot is required. Please wait...

"
	exec &>/dev/null
	sync

	sleep 6
	dbus-send --print-reply --system --dest=com.exor.EPAD "/" com.exor.EPAD.restartSystemWithImage int32:1
fi

echo "USBUpdater v$VERSION"

psplash-write "MSG Bootstrapping BSP updater...
"

create_updatefs()
{
	# Create tmpfs mount point
	mkdir -p "$UPDATEFS"

	if [ "$ARCH" == "arm64" ]; then
		UPDATEOS_MAX_MB="180"
		UPDATEOS_FILE="src/updateos_64.img"
	else
		UPDATEOS_MAX_MB="135"
		UPDATEOS_FILE="src/updateos.img"
	fi
	mount -t tmpfs tmpfs -o size="${UPDATEOS_MAX_MB}M" "$UPDATEFS"

	echo "Using updateos file: $UPDATEOS_FILE"

	tar xf "$UPDATEOS_FILE" --warning=none -C "$UPDATEFS" &> /dev/null || die "Failed to extract updateos image: $UPDATEOS_FILE"

	mkdir -p "$UPDATEFS/proc"
	mount -t proc proc "$UPDATEFS/proc"

	mkdir -p "$UPDATEFS/sys"
	mount -t sysfs sysfs "$UPDATEFS/sys"

	mkdir -p "$UPDATEFS/dev"
	mount -o bind /dev "$UPDATEFS/dev"
	mount -t devpts devpts "$UPDATEFS/dev/pts"

	mkdir -p "$UPDATEFS/run"
	ln -sf /run "$UPDATEFS/var/run"
	mount --move /run "$UPDATEFS/run"

	[ -e "$UPDATEFS/run/initctl" ] && ln -s /run/initctl "$UPDATEFS/dev/initctl"

	mkdir -p "$UPDATEFS/var/lib"
	mount -o bind /var/lib "$UPDATEFS/var/lib"

	mkdir -p "$UPDATEFS/var/volatile"
	mount -o bind /var/volatile "$UPDATEFS/var/volatile"

	rm -rf "$UPDATEFS/tmp"
	ln -sf /var/volatile/tmp "$UPDATEFS/tmp"

	mkdir -p "$UPDATEFS/old_root"

	# use a copy to shadow since factory partition will be unmounted
	cp /mnt/factory/shadow "$UPDATEFS/etc/shadow"

	mkdir -p "$UPDATEFS/mnt/usbmemory"
	mount -o bind /mnt/usbmemory "$UPDATEFS/mnt/usbmemory"

	# debugging
	mkdir -p "$UPDATEFS/etc/ssh"
	cp -a /etc/ssh/*key*  "$UPDATEFS/etc/ssh"
}

if uname -a | grep -q 'aarch64 GNU/Linux$'; then
    echo "Detected 64-bit ARM platform"
    USBUPDATER_FILE="src/usbupdater_64"
    ARCH="arm64"
else
    echo "Assuming 32-bit ARM platform"
    USBUPDATER_FILE="src/usbupdater"
    ARCH="arm32"
fi

[ -e "$UPDATEFS" ] || create_updatefs

while [ ! -e /tmp/.X11-unix/X0 ] && !( pidof node); do
	sleep 1;
done

/etc/init.d/dbus-1 stop
/etc/init.d/jmuconfig stop
killall EPAD; rm -f /dev/shm/sem.epadlowlevelsem

# BSP-2623 --make-shared causes pivot_root to fail, so revert to private mode
mount --make-rprivate /mnt

[ -e /etc/rotation ] && rotation=$(cat /etc/rotation)
[ -z "$rotation" ] && rotation=0

cd "$UPDATEFS"
pivot_root . old_root

OLD_ROOT=/old_root \
ROTATION=$rotation \
USBDIR=/mnt/usbmemory \
	chroot . /bin/bash -c "/mnt/usbmemory/${USBUPDATER_FILE}"

if [ "$?" -ne 0 ]; then
	# xsplash needs to be run from original/old root
	if [ -x /old_root/usr/bin/xsplash ]; then
		chroot old_root /bin/bash -c "DISPLAY=:0 xsplash --no-taptap &"
		sleep 1
		export TMPDIR=old_root/var/volatile/tmp
	else
		killall -9 psplash
		psplash --notouch --infinite-progress --angle $rotation &>/dev/null &
	fi
	die "Failed starting usbupdater"
fi
