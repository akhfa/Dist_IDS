# Deskripsi:
# 	Digunakan untuk membuat exchange dan queue

# Format: 
#	./add_exchange_queue.sh <exchange name> <queue name>

# Keterangan: 
# 	exchange	= cluster
# 	queue 		= node

#!/bin/sh
rabbitmqadmin -V ta -u ta -p BuatTA -H rabbitmq.akhfa.me declare exchange name=$1 type=fanout
rabbitmqadmin -V ta -u ta -p BuatTA -H rabbitmq.akhfa.me declare queue name=$2 durable=true
rabbitmqadmin -V ta -u ta -p BuatTA -H rabbitmq.akhfa.me declare binding source=$1 destination=$2
