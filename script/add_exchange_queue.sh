# Deskripsi:
# 	Digunakan untuk membuat exchange dan queue

# Format: 
#	./add_exchange_queue.sh <rabbitmq-host> <vhost> <user> <password> <exchange> <exchange_type> <queue>

# Keterangan:
#       host            = host dari rabbitmq
#       vhost           = virtual host rabbitmq
#       user            = user rabbitmq
#       password        = password dari user rabbitmq
#       exchange        = cluster
#		exchange_type	= direct / fanout
#		queue 			= Queue

#!/bin/sh
# assign variable from user input
host=$1
vhost=$2
user=$3
password=$4
exchange=$5
exchange_type=$6
queue=$7

# add exchange dan queue pada server rabbitmq
rabbitmqadmin -V $vhost -u $user -p $password -H $host declare exchange name=$exchange type=$exchange_type
rabbitmqadmin -V $vhost -u $user -p $password -H $host declare queue name=$queue durable=true
rabbitmqadmin -V $vhost -u $user -p $password -H $host declare binding source=$exchange destination=$queue
