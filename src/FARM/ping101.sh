#!/bin/bash

if ! [ -x "$(type -P ping)" ]; then
  echo "ERROR: script requires ping"
  exit 1
fi
 
if [ "$#" -ne "2" ]; then
  echo "Usage: $(basename $0) [ # ] [ host ]"
  exit 1
else
  RUNS=$1
  host=$2
fi

log=log/${host}_ping.log
 
if [ -f $log ]; then
  echo removing $log
  rm $log
fi
 
echo "=================================================================="
echo " Results"
echo "=================================================================="
echo " target host .... $host"
echo "------------------------------------------------------------------"

 
for run in $(seq 1 $RUNS); do
  ping -c $RUNS $host >> $log
  echo -e " run $run: \t $(tail -n 1 $log | awk -F '/' '{print $5}')"
done
 
avg=$(awk -v RUNS=$RUNS -F '/' '{sum+=$5; avg=sum/RUNS} END {print avg}' $log)
 
 
echo $info ", " $count
echo "------------------------------------------------------------------"
echo " average ....... $avg Mbits/sec"
echo
echo "see $log for details"
