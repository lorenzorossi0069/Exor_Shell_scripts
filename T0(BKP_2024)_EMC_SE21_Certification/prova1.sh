#!/bin/bash

# Numero di CPU
CPUS=$(grep -c ^processor /proc/cpuinfo)

# Interfaccia da utilizzare
DEV=wlan0

# Configurazione di base di pktgen
pgset() {
    local result
    echo $1 > $PGDEV
    result=$(cat $PGDEV | fgrep "Result: OK")
    if [ "$result" = "" ]; then
        cat $PGDEV | fgrep Result
    fi
}

# Configurazione di base di un thread
pg() {
    PGDEV=/proc/net/pktgen/$1
    shift
    while [ -n "$1" ]; do
        pgset "$1"
        shift
    done
}

# Start di un thread
pgrun() {
    PGDEV=/proc/net/pktgen/pgctrl
    echo "start" > $PGDEV
    cat $PGDEV
}

# Configurazione iniziale
pgset "rem_device_all"
pgset "add_device $DEV"

# Configurazione della trasmissione
pg $DEV "clone_skb 0" "pkt_size 64" "count 0" "delay 0"

# Inizia la trasmissione
pgrun

