# Deskripsi:
#	Digunakan untuk membuat cluster baru maupun node baru

# Format:
#	./add_cluster.sh <host> <vhost> <user> <password> <exchange>

# Keterangan:
#	host		= host dari rabbitmq
#	vhost		= virtual host rabbitmq
#	user		= user rabbitmq
# 	password	= password dari user rabbitmq
#   exchange    = cluster

#!/bin/sh

# Install dependensi
echo "Installing dependencies..."
yum install -y wget

# assign variable from user input
echo "assign variable"
host=$1
vhost=$2
user=$3
password=$4
exchange=$5
queue=$(hostname)
durable=true 		# ganti false jika diinginkan

# Download all script
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-jdk.sh
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-logstash.sh
wget https://raw.githubusercontent.com/akhfa/ta/master/script/add_exchange_queue.sh

# Get exec permission
chmod +x install-jdk.sh
chmod +x install-logstash.sh
chmod +x add_exchange_queue.sh

# Install JDK
echo "Installing Oracle JDK..."
./install-jdk.sh

# Install rabbitmqadmin untuk menambah exchange dan queue
echo "Install rabbitmqadmin"
wget "http://$host:15672/cli/rabbitmqadmin"
chmod +x rabbitmqadmin
mv rabbitmqadmin /usr/bin

# Install Logstash
echo "Installing logstash and set logstash user as root..."
./install-logstash.sh
sed -i '/#LS_USER=logstash/a LS_USER=root' /etc/sysconfig/logstash

# Install exchange (jika belum ada) dan queue untuk node ini
echo "Adding exchange and queue"

# Download config input logstash dan ubah parameter sesuai input user
echo "Downloading logstash input config"
wget https://raw.githubusercontent.com/akhfa/ta/master/config/cluster/01-sqi-input.conf
# input file log
sed -i "s,<path>,\"/var/log/nginx/access_log\"," 01-sqi-input.conf
# Input general
sed -i "s/<host>/\"$host\"/" 01-sqi-input.conf
sed -i "s/<vhost>/\"$vhost\"/" 01-sqi-input.conf
sed -i "s/<user>/\"$user\"/" 01-sqi-input.conf
sed -i "s/<password>/\"$password\"/" 01-sqi-input.conf
sed -i "s/<durable>/\"$durable\"/" 01-sqi-input.conf
# input untuk mendapatkan pattern dari rabbitmq
sed -i "s/<pattern-exchange>/\"pattern-exchange\"/" 01-sqi-input.conf
sed -i "s/<pattern-queue>/\"pattern-$queue\"/" 01-sqi-input.conf
./add_exchange_queue.sh $host $vhost $user $password pattern-exchange fanout pattern-$queue
# Input untuk input cluster sebagai sumber dari exec iptables
sed -i "s/<cluster-exchange>/\"cluster-$exchange\"/" 01-sqi-input.conf
sed -i "s/<cluster-queue>/\"cluster-$queue\"/" 01-sqi-input.conf
./add_exchange_queue.sh $host $vhost $user $password cluster-$exchange fanout cluster-$queue
# mv conf file
mv 01-sqi-input.conf /etc/logstash/conf.d/

# Download config output logstash dan ubah parameter sesuai input user
echo "Downloading logstash output config"
wget https://raw.githubusercontent.com/akhfa/ta/master/config/cluster/01-sqi-output.conf
# output general
sed -i "s/<host>/\"$host\"/" 01-sqi-output.conf
sed -i "s/<vhost>/\"$vhost\"/" 01-sqi-output.conf
sed -i "s/<user>/\"$user\"/" 01-sqi-output.conf
sed -i "s/<password>/\"$password\"/" 01-sqi-output.conf
sed -i "s/<durable>/\"$durable\"/" 01-sqi-output.conf

# output cluster
sed -i "s/<cluster-exchange>/\"$exchange\"/" 01-sqi-output.conf
# output exchange ke elasticsearch
sed -i "s/<elastic-exchange>/\"elastic\"/" 01-sqi-output.conf
# mv config ke tempat seharusnya
mv 01-sqi-output.conf /etc/logstash/conf.d/

# Install iptables services (Firewalld akan dinonaktifkan)
echo "Disabling firewalld and installing iptables-services"
systemctl stop firewalld
systemctl disable firewalld
yum install iptables-services -y
echo "Buka port 4369,25672,5671,5672,15672,61613,61614,1883,8883,5555,16384,9200,9300"
echo "Silahkan sesuaikan rules iptables dan start iptables"
