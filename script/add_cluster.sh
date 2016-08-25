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

# assign variable from user input
# exchange log karena script ini hanya digunakan untuk mengirim log ke rabbitmq
echo "assign variable"
if [ "$1" == "" ]; then
	read -p "RabbitMQ host: " -e host
	read -p "RabbitMQ vhost: " -e vhost
	read -p "RabbitMQ user: " -e user
	read -p "RabbitMQ password: " -e password
	read -p "Cluster name: " -e clusterName
	read -p "Log location (masukkan di antara tanda ''): " -e logLocation
else
	host=$1
	vhost=$2
	user=$3
	password=$4
	clusterName=$5
	logLocation=$6
fi
exchange=log 		# Exchange tujuan pengiriman log
queue=log
durable=true 		# ganti false jika diinginkan

notifExchange=$clusterName
notifQueue=$notifExchange-$(hostname)

# Install dependensi
echo "Installing dependencies..."
yum install -y wget

# Download all script
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/install-beaver.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/add_exchange_queue.sh

# Get exec permission
chmod +x install-beaver.sh
chmod +x add_exchange_queue.sh

# Install Beaver
echo "Installing beaver..."
./install-beaver.sh $host $vhost $user $password $exchange $queue $clusterName $logLocation

# Install rabbitmqadmin untuk menambah exchange dan queue
echo "Installing rabbitmqadmin..."
wget -q "http://$host:15672/cli/rabbitmqadmin"
chmod +x rabbitmqadmin
mv rabbitmqadmin /usr/bin

# Menambahkan exchange queue untuk menerima notifikasi serangan
./add_exchange_queue.sh $host $vhost $user $password $notifExchange fanout $notifQueue

# add beaver service
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/cluster/beaver.service
mv beaver.service /etc/systemd/system/

systemctl start beaver
systemctl enable beaver

# Install iptables services (Firewalld akan dinonaktifkan)
echo "Disabling firewalld and installing iptables-services"
systemctl stop firewalld
systemctl disable firewalld
yum install iptables-services -y
echo "Buka port 5672"
echo "Silahkan sesuaikan rules iptables dan start iptables"

echo "hapus file tidak penting"
rm -f install-beaver.sh
rm -f add_exchange_queue.sh

echo "Add cluster selesai dilakukan."