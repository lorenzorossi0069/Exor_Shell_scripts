#!/bin/bash

#v1.0

cd $(dirname $0)

LOG_PATH=/home/admin
MAX_TIME=100
WAIT_WIFI=1

connectionStatus=disconnected

if [[ ! -f "$LOG_PATH/dateSec.log" ]]; then
    echo "0" > "$LOG_PATH/dateSec.log"
fi

if [[ ! -f "$LOG_PATH/testNumber.log" ]]; then
    echo "0" > "$LOG_PATH/testNumber.log"
fi

#execute this branch ONLY if no reboot process is already in execution
if ps aux | grep reboot | grep -qv grep ; then
	read -r dateSec_old < $LOG_PATH/dateSec.log
	read -r test_number < $LOG_PATH/testNumber.log

	while [[ $connectionStatus != connected ]] ; do

		# update seconds counter (at least first time)
		dateSec_new=$(date +%s)
		delta_time=$((dateSec_new - dateSec_old))

	        #if iw wlan0 link | grep -q SSID ; then
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
	        echo "$(date): Test N $test_number had a delay of $delta_time sec (connectionStatus: $connectionStatus); " >> $LOG_PATH/tooLongReboots.log 
	fi

	#echo "Test $test_number:  $(date): pid=$$ and pid2=$PPID: DELTA TIME=$delta_time :$connectionStatus : ">>$LOG_PATH/dbgInfo.log

fi

