# common functions library

function terminateEmission {
  pkill wpa_supplicant
  pkill hostapd
  pkill udhcpc
  pkill udhcpd
  
  ip link set wlan0 down
  exit 
}
