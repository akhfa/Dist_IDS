# Deskripsi:
# 	Digunakan untuk membuat exchange dan queue

# Format: 
#	./add_exchange_queue.sh <rabbitmq-host> <vhost> <user> <password> <exchange>

# Keterangan:
#       host            = host dari rabbitmq
#       vhost           = virtual host rabbitmq
#       user            = user rabbitmq
#       password        = password dari user rabbitmq
#       exchange        = cluster

#!/bin/sh
# assign variable from user input
host=$1
vhost=$2
user=$3
password=$4
exchange=$5
queue=$(hostname)

# add exchange dan queue pada server rabbitmq
rabbitmqadmin -V $vhost -u $user -p $password -H $host declare exchange name=$exchange type=fanout
rabbitmqadmin -V $vhost -u $user -p $password -H $host declare queue name=$queue durable=true
rabbitmqadmin -V $vhost -u $user -p $password -H $host declare binding source=$exchange destination=$queue
