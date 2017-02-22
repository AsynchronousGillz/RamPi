#!/bin/sh

if [ "$#" -ne "3" ]; then
  echo "Usage: $(basename $0) [ # ] [ host ] [ file ]"
  exit 1
else
  RUNS=$1
  HOST=$2
  FILE=$3
fi
 
USER="anonymous"
PASSWD=""

log=log/${HOST}_ftp.log
 
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
  wget -o $log ftp://${USER}:@${HOST}/${FILE}
  echo -e " run $run: \t $(awk '/saved/{print;f=1}' $log | awk '{print $3, $4}')"
  rm $FILE
done
 
avg=$(awk -v RUNS=$RUNS '/saved/{sum+=$3; avg=sum/RUNS} END {print avg}' $log)
 
 
echo "------------------------------------------------------------------"
echo " average ....... $avg Mbits/sec"
echo
echo "see $log for details"
