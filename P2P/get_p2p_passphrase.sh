#!/bin/bash

# Trova un'interfaccia P2P esistente (es: p2p-wlan0-0)
P2P_IF=$(wpa_cli interface | grep p2p-wlan  | grep -v interface | head -n 1)

if [ -z "$P2P_IF" ]; then
    echo "Nessuna interfaccia P2P trovata."
    exit 1
fi

# Verifica se il gruppo P2P è attivo
RES=$(wpa_cli interface | grep Selected| grep $P2P_IF)
if [ ! -z "$RES" ]; then
	echo "interface $P2P_IF is not active"
	exit 1
fi


# Ottieni la passphrase
PASSPHRASE=$(wpa_cli -i $P2P_IF p2p_get_passphrase)

if [ -z "$PASSPHRASE" ]; then
    echo " Nessuna passphrase trovata. Il gruppo potrebbe non essere ancora attivo o configurato correttamente."
    exit 1
fi

echo "Passphrase per $P2P_IF:"
echo $PASSPHRASE
