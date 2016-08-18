#!/bin/sh

# assign variable from user input
# exchange log karena script ini hanya digunakan untuk mengirim log ke rabbitmq
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
exchange=log
queue=$(hostname)
durable=true 		# ganti false jika diinginkan

# Install dependensi
echo "Installing dependencies..."
yum install -y wget

# Download all script
echo "Downloading all script"
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/install-jdk.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/install-logstash.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/add_exchange_queue.sh

# Get exec permission
chmod +x install-jdk.sh
chmod +x install-logstash.sh
chmod +x add_exchange_queue.sh

# Install JDK
echo "Installing Oracle JDK..."
./install-jdk.sh

# Install rabbitmqadmin untuk menambah exchange dan queue
echo "Installing rabbitmqadmin..."
wget -q "http://$host:15672/cli/rabbitmqadmin"
chmod +x rabbitmqadmin
mv rabbitmqadmin /usr/bin

# Install Logstash and set logstash user as root
echo "Installing logstash and set logstash user as root..."
./install-logstash.sh
sed -i '/#LS_USER=logstash/a LS_USER=root' /etc/sysconfig/logstash

echo "Downloading logstash input config"
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/cluster/01-sqi-input.conf

# Menambahkan exchange dan queue yang dibutuhkan
./add_exchange_queue.sh $host $vhost $user $password log fanout log
./add_exchange_queue.sh $host $vhost $user $password elastic-true fanout elastic-true
./add_exchange_queue.sh $host $vhost $user $password elastic-false fanout elastic-false
./add_exchange_queue.sh $host $vhost $user $password pattern fanout pattern-$queue

# Download config input logstash dan ubah parameter sesuai input user
echo "Downloading logstash input config"
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/parser/01-sqi-input.conf

# Input general
sed -i "s/<host>/\"$host\"/" 01-sqi-input.conf
sed -i "s/<vhost>/\"$vhost\"/" 01-sqi-input.conf
sed -i "s/<user>/\"$user\"/" 01-sqi-input.conf
sed -i "s/<password>/\"$password\"/" 01-sqi-input.conf
sed -i "s/<durable>/$durable/" 01-sqi-input.conf

# input untuk mendapatkan pattern dari rabbitmq
sed -i "s/<pattern-exchange>/\"pattern\"/" 01-sqi-input.conf
sed -i "s/<pattern-queue>/\"pattern-$queue\"/" 01-sqi-input.conf

# mv config ke logstash
mv 01-sqi-input.conf /etc/logstash/conf.d/

# set logstash autoreload config file
sed -i "s,LS_OPTS="",LS_OPTS="--auto-reload"," /etc/rc.d/init.d/logstash

systemctl start logstash
systemctl enable logstash

rm -f add_exchange_queue.sh
rm -f install-jdk.sh
rm -f install-logstash.sh

echo "Instalasi server parser selesai."