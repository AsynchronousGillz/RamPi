#!/bin/bash

RED="\e[1;31m"
GRN="\e[1;32m"
BLU="\e[1;34m"
NOW="\e[0m"

function driverInstallation() {
    if [ -d "./mt7610u_wifi_sta_v3002_dpo_20130916" ]; then 
        rm -rf ./mt7610u_wifi_sta_v3002_dpo_20130916
    fi
    export GIT_SSL_NO_VERIFY=1
    git clone https://github.com/Myria-de/mt7610u_wifi_sta_v3002_dpo_20130916.git
    if [ $? -ne 0 ]; then 
        echo -e "[ ${RED}ERROR${NOW} ]: failed to donwload driver."
        return 1
    else
        echo -e "[ ${GRN}OK${NOW} ]: driver downloaded."
    fi
    export GIT_SSL_NO_VERIFY=0
    cd ./mt7610u_wifi_sta_v3002_dpo_20130916 && make
    if [ $? -ne 0 ]; then 
        echo -e "[ ${RED}ERROR${NOW} ]: make failed."
        return 1
    else
        echo -e "[ ${GRN}OK${NOW} ]: make complete."
    fi
    make install
    if [ $? -ne 0 ]; then 
        echo -e "[ ${RED}ERROR${NOW} ]: make install failed."
        return 1
    else
        echo -e "[ ${GRN}OK${NOW} ]: make install complete."
    fi
    cp RT2870STA.dat /etc/Wireless/RT2870STA/RT2870STA.dat && cd ../
    if [ $? -ne 0 ]; then 
        echo -e "[ ${RED}ERROR${NOW} ]: driver installation failed. "
        return 1
    else
        echo -e "[ ${GRN}OK${NOW} ]: driver installation complete."
    fi
    return 0
}

function driverUpdate() {
    cd mt7610u_wifi_sta_v3002_dpo_20130916
    make && make install
    if [ $? -ne 0 ];then 
        echo -e "[ ${RED}ERROR${NOW} ]: make install failed."
        return 1
    else
        echo -e "[ ${GRN}OK${NOW} ]: make install complete."
    fi
}

cd "${0%/*}" # current working directory in the script

if ! [ -f "/etc/debian_version" ]; then 
    echo -e "[ ${RED}ERROR${NOW} ]: Not a debian based system."
    exit 1
fi

if ! [ -x "$(type -P apt-get)" ]; then
    echo -e "[ ${RED}ERROR${NOW} ]: script requires apt-get."
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
    echo -e "[ ${RED}ERROR${NOW} ]: Not root."
    return 1
fi

if [ "$#" -ne "0" ]; then
    echo -e "[ ${RED}ERROR${NOW} ]: Usage: $(basename $0)"
    exit 1
fi

LOG=../log/${HOST}_install.log
HOSTFILE=./hostname
USER="pi" 
 
if [ -f $LOG ]; then
  echo removing $LOG
  rm $LOG
fi
 
echo "=================================================================="
echo "  Starting Install"
echo "=================================================================="

echo "------------------------------------------------------------------"

echo "Update and install."
apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get -y autoremove && 
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to update system."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: update complete."
fi

mv ./ntp.conf /etc/ntp.conf && ntpd && service ntp start
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: could not setup up time."
    exit 1
else
    sleep 5
    echo -e "[ ${GRN}OK${NOW} ]: time is set to: $(date)"
fi

HOST=$(cat $HOSTFILE)
hostname $HOST && mv $HOSTFILE /etc/hostname
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to change hostname."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: hostname changed."
fi


./dynDNS.sh
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: could not update DNS."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: DNS updated."
fi

driverInstallation
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: could not install driver."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: driver installed."
fi

cp ./interfaces /etc/network/interfaces && cp ./wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: could not setup wireless."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: wireless setup."
fi

cp ./rc.local /etc/rc.local
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: could not setup wireless."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: wireless setup."
fi

echo "------------------------------------------------------------------"
echo -e "[ ${GRN}OK${NOW} ]: install complete."
echo "=================================================================="
