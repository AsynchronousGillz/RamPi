#!/bin/sh

if [ "$#" -ne "3" ]; then
  echo "Usage: $(basename $0) [ host ] [ user ] [ file ]"
  exit 1
fi
 

ftp -n $1 << EOF
quote USER $2
quote PASS ""
put $4
quit
EOF
