#!/usr/bin/env bash


RED="\e[1;31m"
GRN="\e[1;32m"
BLU="\e[1;34m"
NOW="\e[0m"

cd "${0%/*}" # current working directory in the script

function getLogDate() {
    date +%Y-%m-%d%H:%M:%S >> $1
}

function wifiCheck() {
    LOCKFILE='/var/run/wdt101.pid'
    INTERFACE='ra0'
    LOG='log/wifi_check.log'
    > $LOG

    INT=`grep "ra0" /proc/net/dev`
    if [ ! -n "$INT" ]; then
        echo "No ra0 found." >> $LOG
        echo "No ra0 found."
#        return 1
    fi

    echo "Starting WDT for $INTERFACE"
    getLogDate $LOG

    if [ "$(id -u)" != "0" ]; then
        echo "Not root." >> $LOG
        echo "Not root."
        return 1
    fi

    if [ -e $LOCKFILE ];then
        PID=$(cat $LOCKFILE)
        if kill -0 &>1 > /dev/null $PID; then
            return 1
        else
            rm $LOCKFILE
        fi
    fi

    echo $$ > $LOG
    currentIP=$(ip a l $INTERFACE | gawk --re-interval '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/{print $0}' | cut -d ' ' -f 6 | cut -d '/' -f 1 | tail -n 1)
    if ! [ -z $currentIP ]; then
        echo "Network is Up." >> $LOG
        echo "Network is Up."
    else
        echo "Network is Down. Attempting to reconnect." >> $LOG
        echo "Network is Down. Attempting to reconnect."
        sudo ifconfig $INTERFACE down
        sleep 5
        sudo ifconfig $INTERFACE up
        sleep 10
    fi
    dnsFunc

    getLogDate $LOG
    currentIP=$(ip a l $INTERFACE | gawk --re-interval '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/{print $0}' | cut -d ' ' -f 6 | cut -d '/' -f 1 | tail -n 1)
    echo "IP for $INTERFACE is: $currentIP" >> $LOG
    echo "IP for $INTERFACE is: $currentIP"
    python3 /home/pi/PI/net_log.py ra0 > /var/www/html/info.html
}

function curlFunc() { 
    HOSTS=$'www.colostate.edu\nwww.google.com\nwww.yahoo.com\nwww.nfl.com\nwww.facebook.com\nwww.nhl.com'
    SLE=$(shuf -i 0-60 -n 1)
    while read -r line; do
        ./curl101.sh 5 $line
        if [ $? -ne 0 ];then return 1; fi
        echo "Now sleep for $SLE"
        sleep $SLE
    done <<< "$HOSTS"
}

function dnsFunc(){
    if [ -f ./config/currentIp ];then
        touch ./config/currentIp
    fi

    if [ "$(cat ./config/currentIp)" != "$currentIP" ];then
        ./config/dynDNS.sh
        $currentIp > ./config/currentIp
    fi
}

function ftpFunc() {  
    HOST="129.82.100.233"
    FILES=$'1MBfile\n10MBfile\n20MBfile\n50MBfile\n100MBfile'
    SLE=$(shuf -i 0-60 -n 1)
    while read -r line; do
        if [ -f $line ]; then
            echo "Now removing $line"
            rm $line
        fi
    done <<< "$FILES"
    while read -r line; do
        ./ftp101.sh 5 $HOST $line
        if [ $? -ne 0 ];then return 1; fi
        SLE=$(shuf -i 0-60 -n 1)
        echo "Now sleep for $SLE"
        sleep $SLE
    done <<< "$FILES"
    while read -r line; do
        echo "Now removing $line"
        rm $line
    done <<< "$FILES"
}

function iperfFunc() { 
    HOSTS=$'129.82.100.233'
    SLE=$(shuf -i 0-60 -n 1)
    while read -r line; do
        ./iperf101.sh 5 $line
        if [ $? -ne 0 ];then return 1; fi
        echo "Now sleep for $SLE"
        sleep $SLE
    done <<< "$HOSTS"
}

function pingFunc() {
    HOSTS=$'www.colostate.edu\nwww.google.com\nwww.yahoo.com\nwww.nfl.com\nwww.facebook.com\nwww.nhl.com'
    SLE=$(shuf -i 0-60 -n 1)
    while read -r line; do
        ./ping101.sh 5 $line
        if [ $? -ne 0 ];then return 1; fi
        echo "Now sleep for $SLE"
        sleep $SLE
    done <<< "$HOSTS"
}

function wgetFunc() {
    HOST="129.82.100.233"
    FILES=$'1MBfile\n10MBfile\n20MBfile\n50MBfile\n100MBfile'
    SLE=$(shuf -i 0-10 -n 1)
    LG="log/wget_${HOST}_"
    while read -r line; do
        if [ -f $line ]; then
            echo "Now removing $line"
            rm $line
        fi
    done <<< "$FILES"
    while read -r line; do
        WLOG=${LG}${line}.log
        if [ -f $WLOG ]; then
            rm $WLOG
        fi
        wget -o $WLOG http://${HOST}/${line}
        if [ $? -ne 0 ];then return 1; fi
        echo "Now sleep for $SLE"
        sleep $SLE
    done <<< "$FILES"
    while read -r line; do
        echo "Now removing $line"
        rm $line
    done <<< "$FILES"
}

function configFunc() {
    HOST="129.82.100.233"
    FILE='wdtrc'
    if [ -f $FILE ]; then rm ./${FILE}; fi
    wget http://${HOST}/${FILE}
}

function runConfig() {

    if ! [ -f ./wdtrc ]; then
        echo -e "[ ${RED}ERROR${NOW} ]: no config file found."
        return 1
    fi
    FILE='wdtrc'
    while read -r line; do
        echo $line
        if [ "$line" == "\#*" ]; then continue; fi
        if [ "$line" == "wget" ];then testFunc 0; fi
        if [ "$line" == "curl" ];then testFunc 1; fi
        if [ "$line" == "ping" ];then testFunc 2; fi
        if [ "$line" == "ftp" ];then testFunc 3; fi
        if [ "$line" == "iperf" ];then testFunc 4; fi
        if [ "$line" == "shutdown" ];then sudo poweroff; fi
        if [ $? -ne 0 ];then return 1; fi
    done < "$FILE"

}

function randomFunc() {

    INTERFACE='ra0'
    RUNS=$1
    LOG="log/wdt.log"
    currentIP=$(ip a l $INTERFACE | gawk --re-interval '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/{print $0}' | cut -d ' ' -f 6 | cut -d '/' -f 1 | tail -n 1)

    if [ ! -f ./config/currentIp ]; then
        $currentIP > ./config/currentIp
    fi

    if [ -f $LOG ]; then
        echo removing $LOG
        rm $LOG
    fi

    echo "=================================================================="
    echo " Results"
    echo "=================================================================="
    echo " TIME .......... $(date)"
    echo "------------------------------------------------------------------"

    for run in $(seq 1 $RUNS); do
        wifiCheck
        PICK=$(shuf -i 0-4 -n 1)
        SLEEP=$(shuf -i 0-360 -n 1)
        testFunc $PICK
        echo "Sleep for: $SLEEP"
        sleep $SLEEP
    done

    echo "------------------------------------------------------------------"
    echo " TIME ....... $(date)"
    echo
    echo "see $LOG for details"
}

function testFunc() {
    wifiCheck
    PICK=$1
    if [ $PICK -eq 0 ];then
        wgetFunc
    elif [ $PICK -eq 1 ];then
        curlFunc
    elif [ $PICK -eq 2 ];then
        pingFunc
    elif [ $PICK -eq 3 ];then
        ftpFunc
    else
        iperfFunc
    fi
}


if [ "$#" -gt "2" ]; then
    echo -e " [ ${RED}ERROR${NOW} ] Usage: $(basename $0) [ -s | -d | -c | -r ] [ # ]"
    echo "  [ -s ] single wireless check"
    echo "  [ -d ] forever wireless check"
    echo "  [ -c ] get updated config from server"
    echo "  [ -t ] [ # ] test single function"
    echo "  [ -r ] [ # ] run random test"
    exit 1
fi

if [ "$#" -eq "1" ] && [ "$1" == "-s" ]; then
    wifiCheck
    exit 0
fi

if [ "$#" -eq "1" ] && [ "$1" == "-d" ]; then
    while true; do
        SLEEP=$(shuf -i 0-360 -n 1)
        wifiCheck
        echo "Sleep for: $SLEEP"
        sleep $SLEEP
        dnsFunc
    done
    exit 0
fi

if [ "$#" -eq "2" ] && [ "$1" == "-t" ]; then
    testFunc $2 
    exit 0
fi

if [ "$#" -eq "2" ] && [ "$1" == "-r" ]; then
    randomFunc $2 
    exit 0
fi

if [ "$#" -eq "1" ] && [ "$1" == "-c" ]; then
    configFunc
fi

runConfig
