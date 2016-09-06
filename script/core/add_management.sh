# Deskripsi:
#	Digunakan untuk membuat server managemen baru

# Format:
#	./add_cluster.sh <host> <vhost> <user> <password>

# Keterangan:
#	host		= host dari rabbitmq
#	vhost		= virtual host rabbitmq
#	user		= user rabbitmq
# 	password	= password dari user rabbitmq

#!/bin/bash
# assign variable from user input

if [ "$1" == "" ]; then
	read -p "RabbitMQ host: " -e host
	read -p "RabbitMQ vhost: " -e vhost
	read -p "RabbitMQ user: " -e user
	read -p "RabbitMQ password: " -e password
else
	host=$1
	vhost=$2
	user=$3
	password=$4
fi

durable=true

yum install wget -y

echo "Downloading script..."
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/others/install-logstash.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/others/install-elasticsearch.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/others/install-jdk.sh
chmod +x install-logstash.sh
chmod +x install-elasticsearch.sh
chmod +x install-jdk.sh

echo "Installing jdk"
./install-jdk.sh

echo "Installing logstash"
./install-logstash.sh
# set logstash autoreload config file
sed -i "s,LS_OPTS="",LS_OPTS="--auto-reload"," /etc/rc.d/init.d/logstash
sed -i '/#LS_USER=logstash/a LS_USER=root' /etc/sysconfig/logstash

echo "Downloading config logstash"
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/management/01-log-input.conf
# Input general
sed -i "s/<host>/\"$host\"/" 01-log-input.conf
sed -i "s/<vhost>/\"$vhost\"/" 01-log-input.conf
sed -i "s/<user>/\"$user\"/" 01-log-input.conf
sed -i "s/<password>/\"$password\"/" 01-log-input.conf
sed -i "s/<durable>/$durable/" 01-log-input.conf
sed -i 's,<elastic-true>,"elastic-true",' 01-log-input.conf
sed -i 's,<elastic-false>,"elastic-false",' 01-log-input.conf

wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/management/01-log-output.conf

mv 01-log-input.conf /etc/logstash/conf.d
mv 01-log-output.conf /etc/logstash/conf.d

echo "Installing elasticsearch"
./install-elasticsearch.sh

systemctl start logstash
systemctl start elasticsearch
systemctl enable logstash
systemctl enable elasticsearch

echo "Remove unneeded script"
rm -f install-logstash.sh install-elasticsearch.sh install-jdk.sh

echo "Done!"
