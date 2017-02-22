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

ping -c 1 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "[ ${RED}ERROR${NOW} ]: Please check network connection."
    exit 1
fi

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
    exit 1
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

driverInstallation
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: could not install driver."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: driver installed."
fi

echo "------------------------------------------------------------------"
echo -e "[ ${GRN}OK${NOW} ]: install complete will now power off."
echo "=================================================================="
sudo poweroff
