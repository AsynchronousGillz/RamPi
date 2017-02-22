#!/bin/bash
 
if ! [ -x "$(type -P ab)" ]; then
  echo "ERROR: script requires apache bench"
  exit 1
fi

# echo "1. Number of times to repeat test (e.g. 10)"
# echo "2. Total NUMBER of requests per run (e.g. 100)"
# echo "3. How many requests to make at once (e.g. 50)"
# echo "4. URL of the SITE to test (e.g. http://giantdorks.org/)"
 
if [ "$#" -ne "4" ]; then
  echo "ERROR: script needs four arguments, where:"
  echo
  echo "Example:"
  echo "  $(basename $0) [ # ] [ # ] [ # ] [ host ]"
  exit 1
else
  RUNS=$1
  NUMBER=$2
  CONCURRENCY=$3
  SITE=$4
fi
 
LOG=log/$(echo $SITE | sed -r 's|https?://||;s|/$||;s|/|_|g;')_ab.log
 
if [ -f $LOG ]; then
  echo removing $LOG
  rm $LOG
fi
 
echo "=================================================================="
echo " Results"
echo "=================================================================="
echo " SITE .......... $SITE"
echo " requests ...... $NUMBER"
echo " CONCURRENCY ... $CONCURRENCY"
echo "------------------------------------------------------------------"
 
for run in $(seq 1 $RUNS); do
  ab -c $CONCURRENCY -n $NUMBER $SITE >> $LOG
  echo -e " run $run: \t $(grep "^Requests per second" $LOG | tail -1 | awk '{print$4}') reqs/sec"
done
 
avg=$(awk -v RUNS=$RUNS '/^Requests per second/ {sum+=$4; avg=sum/RUNS} END {print avg}' $LOG)
 
echo "------------------------------------------------------------------"
echo " average ....... $avg requests/sec"
echo
echo "see $LOG for details"
