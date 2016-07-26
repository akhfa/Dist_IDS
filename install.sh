# Deskripsi:
#	Digunakan untuk membuat cluster baru maupun node baru

# Format:
#	./install.sh <host> <vhost> <user> <password>

# Keterangan:
#	host		= host dari rabbitmq
#	vhost		= virtual host rabbitmq
#	user		= user rabbitmq
# 	password	= password dari user rabbitmq
#   exchange    = exchange untuk menerima log dari semua

#!/bin/sh

echo "assign variable"
host=$1
vhost=$2
user=$3
password=$4
exchange=elastic
queue=$(hostname)
durable=true 		# ganti false jika diinginkan

echo "Install elasticsearch"
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-elasticsearch.sh
chmod +x install-elasticsearch.sh
./install-elasticsearch.sh

echo "Install logstash"
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-logstash.sh
chmod +x install-logstash.sh
./install-logstash.sh

echo "activate exchange and queue"
wget https://raw.githubusercontent.com/akhfa/ta/master/script/add_exchange_queue.sh
chmod +x add_exchange_queue.sh
./add_exchange_queue.sh $host $vhost $user $password $exchange fanout $queue