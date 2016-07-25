# Deskripsi:
#	Digunakan untuk membuat cluster baru maupun node baru

# Format:
#	./add_cluster.sh <host> <vhost> <user> <password> <exchange>

# Keterangan:
#	host		= host dari rabbitmq
#	vhost		= virtual host rabbitmq
#	user		= user rabbitmq
# 	password	= password dari user rabbitmq
#       exchange        = cluster

#!/bin/sh

# Install dependensi
echo "Installing dependencies..."
yum install -y wget

# assign variable from user input
host=$1
vhost=$2
user=$3
password=$4
exchange=$5
queue=$(hostname)
durable=true 		# ganti false jika diinginkan

# Install JDK
echo "Installing Oracle JDK..."
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-jdk.sh
chmod +x install-jdk.sh
./install-jdk.sh

# Install Logstash
echo "Installing logstash and set logstash user as root..."
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-logstash.sh
chmod +x install-logstash.sh
./install-logstash.sh

# Install exchange (jika belum ada) dan queue untuk node ini
wget https://raw.githubusercontent.com/akhfa/ta/master/script/add_exchange_queue.sh
chmod +x add_exchange_queue.sh
./add_exchange_queue.sh $host $vhost $user $password $exchange

# Download config input logstash dan ubah parameter sesuai input user
wget https://raw.githubusercontent.com/akhfa/ta/master/config/cluster/01-input-rabbitmq.conf
sed -i "s/<host>/\"$host\"/" 01-input-rabbitmq.conf
sed -i "s/<vhost>/\"$vhost\"/" 01-input-rabbitmq.conf
sed -i "s/<user>/\"$user\"/" 01-input-rabbitmq.conf
sed -i "s/<password>/\"$password\"/" 01-input-rabbitmq.conf
sed -i "s/<exchange>/\"$exchange\"/" 01-input-rabbitmq.conf
sed -i "s/<queue>/\"$queue\"/" 01-input-rabbitmq.conf
sed -i "s/<durable>/\"$durable\"/" 01-input-rabbitmq.conf
mv 01-input-rabbitmq.conf /etc/logstash/conf.d/

# Download config output logstash dan ubah parameter sesuai input user
wget https://raw.githubusercontent.com/akhfa/ta/master/config/cluster/01-output-file.conf
mv 01-output-file.conf /etc/logstash/conf.d/

# Install iptables services (Firewalld akan dinonaktifkan)
echo "Disabling firewalld and installing iptables-services"
systemctl stop firewalld
systemctl disable firewalld
yum install iptables-services -y
echo "Silahkan sesuaikan rules iptables dan start iptables"