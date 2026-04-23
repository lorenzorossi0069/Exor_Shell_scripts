#!/bin/sh

#!/bin/bash

DEST="8.8.8.8"
INTERVAL=1
LOGFILE="cpu_ping_$(date +"%Y-%m-%d_h%H_%M_%S").log"

echo "timestamp,cpu_usage_percent,ping_time_ms" > "$LOGFILE"

get_cpu_usage() {
    read cpu a b c idle rest < /proc/stat
    PREV_IDLE=$idle
    PREV_TOTAL=$((a+b+c+idle))

    sleep 0.5

    read cpu a b c idle rest < /proc/stat
    IDLE=$idle
    TOTAL=$((a+b+c+idle))

    DIFF_IDLE=$((IDLE-PREV_IDLE))
    DIFF_TOTAL=$((TOTAL-PREV_TOTAL))

    echo $(awk "BEGIN {print 100 * (1 - $DIFF_IDLE / $DIFF_TOTAL)}")
}

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    CPU_USAGE=$(get_cpu_usage)

    PING_TIME=$(ping -c 1 -W 1 $DEST | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
    [ -z "$PING_TIME" ] && PING_TIME="timeout"

    echo "$TIMESTAMP,$CPU_USAGE,$PING_TIME" >> "$LOGFILE"

    sleep $INTERVAL
done