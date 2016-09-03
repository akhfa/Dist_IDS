#!/bin/sh
# https://www.rabbitmq.com/install-rpm.html
# https://www.rabbitmq.com/configure.html

read -p "Masukkan domain message broker (enter jika tidak ada): " domain
read -p "Masukkan username administrator RabbitMQ: " username
read -p "Masukkan password administrator RabbitMQ: " password

yum update -y
yum install epel-release -y
yum install htop wget erlang -y

rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/rabbitmq-server-3.6.5-1.noarch.rpm
yum install rabbitmq-server-3.6.5-1.noarch.rpm -y

#start server
chkconfig rabbitmq-server on
systemctl start rabbitmq-server

# add user 
# http://stackoverflow.com/questions/17054533/allowing-rabbitmq-server-connections
rabbitmqctl add_user $username $password
rabbitmqctl set_user_tags $username administrator
rabbitmqctl set_permissions -p / $username ".*" ".*" ".*"

# enable web management + api
# http://stackoverflow.com/questions/22850546/cant-access-rabbitmq-web-management-interface-after-fresh-install
rabbitmq-plugins enable rabbitmq_management

# jika tanpa domain
if [ "$domain" = "" ]; then
	ip=`wget http://ip.akhfa.me -O - -q ;`
	echo "RabbitMQ dapat diakses dari alamat http://$ip:15672"
else
	# jika ada domain
	yum install nginx certbot -y
	systemctl stop nginx
	certbot certonly --standalone --register-unsafely-without-email --agree-tos -d rabbitmq.akhfa.me
	wget https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/message%20broker/domain-nginx.conf
	sed -i "s/<domain>/$domain/" domain-nginx.conf
	mv domain-nginx.conf /etc/nginx/conf.d
	systemctl start nginx
	systemctl enable nginx
	echo "Rabbitmq dapat diakses dari alamat https://$domain"
fi
