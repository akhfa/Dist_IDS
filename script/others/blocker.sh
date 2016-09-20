# Script untuk menambahkan rule iptables

#!/bin/bash
IP=$1
SECONDS=$2
OUTPUT=$(iptables -nL | grep "$IP" | grep "DROP" | grep all)
if [ -z "${OUTPUT}" ]; then # jika belum ada rules nya
	iptables -I INPUT 1 -s $IP -j DROP
	echo "$IP blocked"

	sleep ${SECONDS}

	iptables -D INPUT -s $IP -j DROP
	echo "$IP unblocked"
fi