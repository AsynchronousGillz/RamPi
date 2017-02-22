#!/usr/bin/env bash

if ! [ -x "$(type -P wpa_supplicant)" ]; then
    echo "ERROR: script requires wpa_supplicant"
    exit 1
fi 

if [ "$#" -ne "0" ]; then
  echo "Usage: $(basename $0)"
  exit 1
fi

log=../log/${host}_wifi.log
 
if [ -f $log ]; then
  echo removing $log
  rm $log
fi

wpa_supplicant -i ra0 -D wext -c /etc/wpa_supplicant/wpa_supplicant.conf > $log 2>&1 

return 0
