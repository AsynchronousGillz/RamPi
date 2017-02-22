#!/bin/bash

if ! [ -x "$(type -P iperf3)" ]; then
	echo "ERROR: script requires iperf"
	exit 1
fi

if [ "$#" -ne "2" ]; then
	echo "Usage: $(basename $0) [ HOST # ] [ PORT # ]" >&2 
	exit 1
fi

case "$1" in
	''|*[!0-9]*)
		echo -e " [ error ]: invalid host number [$1]." >&2
		exit 1
		;;
esac

case "$2" in
	''|*[!0-9]*)
		echo -e " [ error ]: invalid port number [$2]." >&2
		exit 1
		;;
esac

NUM=$1
PORT=$2

if [ $NUM -lt 10 ]; then
	NUM="0"${NUM}
fi

LOG=~/FARM/log/${NUM}_iperf.log
DIRECTORY="~/DATA/"
DISPLAY="${DIRECTORY}iperf_${NUM}.json"
HOST="ANT${NUM}.dyn.acns.colostate.edu"
TIME=25

if [ -f $LOG ]; then
	echo removing $LOG
	rm $LOG
fi

echo "=================================================================="
echo " Results"
echo "=================================================================="
echo " target host .... $HOST"
echo "------------------------------------------------------------------"

CHECK=0

while [ $CHECK -eq 0 ]; do
	iperf3 -J -O2 -c $HOST -p $PORT -f m -u -b 2M -t $TIME 1> ${DISPLAY} 2> ${LOG} < /dev/null &
	if [ $? -eq 0 ]; then
		CHECK=1
	else
		sleep $TIME
	fi
done


echo "------------------------------------------------------------------"
echo
echo "see $LOG for details"
