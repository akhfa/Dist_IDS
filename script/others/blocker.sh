# Script untuk menambahkan rule iptables

#!/bin/bash
IP=$1
OUTPUT=$(iptables -nL | grep "$IP" | grep "DROP" | grep all)
if [ -z "${OUTPUT}" ]; then # jika belum ada rules nya
	iptables -A INPUT -s $IP -j DROP
	echo "rule added"
fi