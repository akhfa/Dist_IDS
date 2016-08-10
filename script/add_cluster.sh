# Deskripsi:
#	Digunakan untuk membuat cluster baru maupun node baru

# Format:
#	./add_cluster.sh <host> <vhost> <user> <password>

# Keterangan:
#	host		= host dari rabbitmq
#	vhost		= virtual host rabbitmq
#	user		= user rabbitmq
# 	password	= password dari user rabbitmq

#!/bin/sh

# Install dependensi
echo "Installing dependencies..."
yum install -y wget

# assign variable from user input
# exchange log karena script ini hanya digunakan untuk mengirim log ke rabbitmq
echo "assign variable"
if [$1 == ""]; then
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
exchange=log
queue=$(hostname)
durable=true 		# ganti false jika diinginkan

# Download all script
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-beaver.sh
wget https://raw.githubusercontent.com/akhfa/ta/master/script/add_exchange_queue.sh

# Get exec permission
chmod +x install-beaver.sh
chmod +x add_exchange_queue.sh

# Install Beaver
echo "Installing beaver..."
./install-beaver.sh $host $vhost $user $password $exchange $queue

# Install iptables services (Firewalld akan dinonaktifkan)
echo "Disabling firewalld and installing iptables-services"
systemctl stop firewalld
systemctl disable firewalld
yum install iptables-services -y
echo "Buka port 5672"
echo "Silahkan sesuaikan rules iptables dan start iptables"
