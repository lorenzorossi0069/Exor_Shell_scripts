#!/bin/bash

#v2.0

cd $(dirname $0)

LOG_PATH=/home/admin
MAX_TIME=0 #normally 50
WAIT_WIFI=1

connectionStatus=disconnected

if [[ ! -f "$LOG_PATH/dateSec.log" ]]; then
    echo "0" > "$LOG_PATH/dateSec.log"
fi

if [[ ! -f "$LOG_PATH/testNumber.log" ]]; then
    echo "0" > "$LOG_PATH/testNumber.log"
fi

#execute this branch ONLY if one reboot instance is found
count=$(ps aux | grep reboot | grep -v grep | wc -l)
if [[ $count -eq 1 ]] ; then

	read -r dateSec_old < $LOG_PATH/dateSec.log
	read -r test_number < $LOG_PATH/testNumber.log

	while [[ $connectionStatus != connected ]] ; do

		# update seconds counter (at least first time)
		dateSec_new=$(date +%s)
		delta_time=$((dateSec_new - dateSec_old))

	        if iw wlan0 station dump | grep -q rx ; then
	                connectionStatus=connected
	        else
	                sleep $WAIT_WIFI
	                if [[ $delta_time -gt $MAX_TIME ]] ; then
	                        break
	                fi
	        fi
	done

	# save update seconds to file before reboot
	echo "$dateSec_new" > $LOG_PATH/dateSec.log

	#log test number
	test_number=$((test_number+1))
	echo "$test_number" > $LOG_PATH/testNumber.log

	# log delay to file only if above threshold
	if [[ $delta_time -gt $MAX_TIME ]] ; then
	        echo "$(date): Test N=$test_number: delay=$delta_time sec (connectionStatus: $connectionStatus);[pid=$$; ppid=$PPID] " \
		>> $LOG_PATH/tooLongReboots_opts0_NO_AP_waitxxsec.log 
	fi

	#echo "Test $test_number:  $(date): pid=$$ and pid2=$PPID: DELTA TIME=$delta_time :$connectionStatus : ">>$LOG_PATH/dbgInfo.log

fi

