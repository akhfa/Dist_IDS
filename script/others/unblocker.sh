# Script untuk menghapus rule iptables

#!/bin/bash
IP=$1
OUTPUT=$(iptables -nL | grep "$IP" | grep "DROP" | grep all)
if [ -n "${OUTPUT}" ]; then # jika belum ada rules nya
	iptables -D INPUT -s $IP -j DROP
	echo "rule deleted"
fi