# Deskripsi:
#	Digunakan untuk membuat cluster baru maupun node baru

# Format:
#	./add_cluster.sh <host> <vhost> <user> <password>

# Keterangan:
#	host		= host dari rabbitmq
#	vhost		= virtual host rabbitmq
#	user		= user rabbitmq
# 	password	= password dari user rabbitmq
#	clusterName	= nama cluster
#	logLocation	= lokasi log yang ingin dimonitor
#   dbuser		= User database mysql
#   dbpass		= password database mysql
#	dbname		= nama database yang akan diuji

#!/bin/sh

# assign variable from user input
# exchange log karena script ini hanya digunakan untuk mengirim log ke rabbitmq
if [ "$1" == "" ]; then
	read -p "RabbitMQ host: " -e host
	read -p "RabbitMQ vhost: " -e vhost
	read -p "RabbitMQ user: " -e user
	read -p "RabbitMQ password: " -e password
	read -p "Cluster name: " -e clusterName
	read -p "Log location (masukkan di antara tanda ''): " -e logLocation
	read -p "Masukkan username database: " -e dbuser
	read -p "Masukkan password database: " -e dbpass
	read -p "Masukkan nama database: " -e dbname
	read -p "Masukkan lamanya blocking (seconds): " -e seconds
else
	host=$1
	vhost=$2
	user=$3
	password=$4
	clusterName=$5
	logLocation=$6
	dbuser=$7
	dbpass=$8
	dbname=$9
	seconds=$10
fi
exchange=log 		# Exchange tujuan pengiriman log
queue=log
durable=true 		# ganti false jika diinginkan

notifExchange=notif
notifQueue=$(hostname)

# Install dependensi
echo "Installing dependencies..."
yum install -y wget git

# Download all script
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/others/install-beaver.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/others/install_lamp.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/others/install-jdk.sh

# Get exec permission
chmod +x install-beaver.sh
chmod +x install_lamp.sh
chmod +x install-jdk.sh

# Install rabbitmqadmin untuk menambah exchange dan queue
echo "Installing rabbitmqadmin..."
wget -q "http://$host:15672/cli/rabbitmqadmin"
chmod +x rabbitmqadmin
mv rabbitmqadmin /usr/bin

echo "install lamp server"
./install_lamp.sh

echo "Configure mysql"
mysql -u root -e "use mysql; UPDATE user SET password=PASSWORD('$dbpass') WHERE User='root'; flush privileges;" 

echo "Download php script for sql injection testing"
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/test/inject.php
sed -i "s/<username>/$dbuser/" inject.php
sed -i "s/<password>/$dbpass/" inject.php
sed -i "s/<database>/$dbname/" inject.php
sed -i "s/<nama-cluster>/$clusterName/" inject.php
mv inject.php /var/www/html/test.php

# Install Beaver
echo "Installing beaver..."
./install-beaver.sh $host $vhost $user $password $exchange $queue $clusterName $logLocation

# Menambahkan exchange untuk menerima notifikasi serangan. Queue dibikin saat aplikasi bloker sudah dijalankan
rabbitmqadmin -V $vhost -u $user -p $password -H $host declare exchange name=$notifExchange type=direct

# add beaver service
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/cluster/beaver.service
mv beaver.service /etc/systemd/system/

systemctl start beaver
systemctl enable beaver

# install java
echo "Installing java"
./install-jdk.sh

# Install blocker
echo "install blocker"
wget -q https://github.com/akhfa/Rm-blocker/releases/download/1.0.1/blocker.tar.gz
tar xzf blocker.tar.gz
mv blocker /opt/
chown -R root:root /opt/blocker

wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/cluster/blocker.service
sed -i "s/<host>/$host/" blocker.service
sed -i "s/<vhost>/$vhost/" blocker.service
sed -i "s/<user>/$user/" blocker.service
sed -i "s/<password>/$password/" blocker.service
sed -i "s/<notif-exchange>/$notifExchange/" blocker.service
sed -i "s/<notif-queue>/$notifQueue/" blocker.service
sed -i "s/<cluster-name>/$clusterName/" blocker.service
sed -i "s/<block-long>/$seconds/" blocker.service
mv blocker.service /etc/systemd/system/

wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/others/blocker.sh
mv blocker.sh /opt/blocker/
systemctl start blocker
systemctl enable blocker

# Install iptables services (Firewalld akan dinonaktifkan)
echo "Disabling firewalld and installing iptables-services"
systemctl stop firewalld
systemctl disable firewalld
yum install iptables-services -y
sed -i "s/22/5223/" /etc/sysconfig/iptables
systemctl start iptables
systemctl enable iptables
echo "Silahkan sesuaikan rules iptables sesuai kebutuhan"

echo "Menghapus file tidak penting..."
rm -f install-beaver.sh
rm -f install_lamp.sh
rm -f blocker.tar.gz
rm -f install-jdk.sh

iptables -I INPUT 4 -p tcp --dport 80 -j ACCEPT

echo "Add cluster selesai dilakukan."