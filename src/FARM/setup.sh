#!/bin/bash

RED="\e[1;31m"
GRN="\e[1;32m"
BLU="\e[1;34m"
NOW="\e[0m"

cd "${0%/*}" # current working directory in the script
 
if ! [ -x "$(type -P scp)" ]; then
    echo -e "[ ${RED}ERROR${NOW} ]: script requires scp"
    exit 1
fi

if [ "$#" -ne "1" ]; then
    echo -e "[ ${RED}ERROR${NOW} ]: Usage: $(basename $0) [ host ]"
    exit 1
else
    HOST=$1
fi

LOG=log/${HOST}_setup.log
HOSTFILE=./config/hostname
USER="pi" 
TRANS=0
 
if [ -f $LOG ]; then
  echo removing $LOG
  rm $LOG
fi
 
echo "=================================================================="
echo -e "$GRN Starting Setup $NOW"
echo "=================================================================="
echo " HOST ... $HOST"
echo "------------------------------------------------------------------"

printf " Please enter the new zone: "
read NAME
echo ${NAME}.dyn.acns.colostate.edu > $HOSTFILE
echo "------------------------------------------------------------------"

if [ -f ./config/WDT.tar ]; then
    rm ./config/WDT.tar
fi

tar -cvf ./config/WDT.tar ../FARM/
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: tar failed for ${HOST}."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: tar complete for ${HOST}."
fi
 
cat ~/.ssh/ANT_rsa.pub | ssh ${USER}@${HOST} "mkdir -p ~/.ssh && cat > ~/.ssh/authorized_keys"
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to add ssh key to ${HOST}."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: ssh key added to ${HOST}."
fi

ssh ${USER}@${HOST} "sudo rm -rf /home/pi/FARM/"

scp ./config/WDT.tar ${USER}@${HOST}:~/
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to transfer files to ${HOST}."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: transfer to $HOST complete."
fi

ssh ${USER}@${HOST} "sudo apt-get update"
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to update ${HOST}."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: update complete."
fi

ssh ${USER}@${HOST} "sudo apt-get install -y apache2-utils iperf3 gawk vim dnsutils ntpdate git build-essential raspberrypi-kernel-headers"
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to install packages ${HOST}."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: package installations."
fi

ssh ${USER}@${HOST} "sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get -y autoremove"
if [ $? -ne 0 ];then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to update system."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: update complete."
fi

ssh ${USER}@${HOST} "sudo reboot"
echo -e "[ ${GRN}OK${NOW} ]: reboot in progress please wait.."
sleep 45
ping -c 1 $HOST
if [ $? -ne 0 ]; then 
    echo -e "[ ${RED}ERROR${NOW} ]: $HOST reboot failed."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: reboot complete."
fi

ssh ${USER}@${HOST} "tar -xvf WDT.tar"
if [ $? -ne 0 ]; then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to untar files on ${HOST}."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: untar complete."
fi

ssh ${USER}@${HOST} "sudo ~/FARM/config/install.sh"
if [ $? -ne 0 ]; then 
    echo -e "[ ${RED}ERROR${NOW} ]: failed to complete installation on ${HOST}."
    exit 1
else
    echo -e "[ ${GRN}OK${NOW} ]: installation complete."
fi

echo "------------------------------------------------------------------"
echo -e "[ ${GRN}OK${NOW} ]: setup is now finshed. see $LOG for details."
echo "------------------------------------------------------------------"
echo
echo "Installation is now finished. Will now powerdown ${HOST}."
ssh ${USER}@${HOST} "sudo poweroff"
