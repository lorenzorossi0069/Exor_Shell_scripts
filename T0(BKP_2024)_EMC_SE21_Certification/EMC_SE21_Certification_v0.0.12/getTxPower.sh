#!/bin/bash

#note: with AX210 max is 2100 (21.00 dBm), bigger values are clamped

echo "Tx power set to: $(iw wlan0 info | grep -i power)"
