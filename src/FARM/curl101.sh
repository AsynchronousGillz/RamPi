#!/bin/bash

if [ "$#" -ne "2" ]; then
  echo "Usage: $(basename $0) [ # ] [ host ]"
  exit 1
else
  RUNS=$1
  HOST=$2
fi
 
log=log/${HOST}_curl.log
 
if [ -f $log ]; then
  rm $log
fi
 
echo "["
 
for run in $(seq 1 $RUNS); do
  curl -w "@config/curl_format.txt" -o /dev/null -s $HOST >> $log
#  echo -e "\t $(tail -n 1 $log | awk -F ' ' '{print $2","}')"
done

AVG=$(awk -v RUNS=$RUNS '/ / {getline; sum+=$2; avg=sum/RUNS} END {print avg}' $log)
 
echo "]"
