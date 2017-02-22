#!/usr/bin/env bash
  
IPV4=$(ip a | gawk --re-interval '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/{print $0}' | cut -d ' ' -f 6 | cut -d '/' -f 1 | tail -n 1)
  
NS=129.82.103.78
DOMAIN=$(hostname)
ZONE=dyn.acns.colostate.edu.
  
nsupdate << EOF
server $NS
zone $ZONE
update delete $DOMAIN A
update add $DOMAIN 86400 A $IPV4
show
send
EOF
