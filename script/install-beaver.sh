#!/bin/sh

if($1 == ""); then
	echo "rabbitmq host:"
	input -e rabbitmq-host
	echo "rabbitmq vhost:"
	input -e rabbitmq-vhost
	echo "rabbitmq username:"
	input -e rabbitmq-username
	echo "rabbitmq password:"
	input -e rabbitmq-password
	echo "rabbitmq exchange:"
	input -e rabbitmq-exchange
else
	rabbitmq-host = $1
	rabbitmq-vhost = $2
	rabbitmq-username = $3
	rabbitmq-password = $4
	rabbitmq-exchange = $5
fi

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install beaver==36.2.0
mkdir /etc/beaver

wget -O https://raw.githubusercontent.com/akhfa/ta/master/config/cluster/beaver.conf

sed -i "s/<rabbitmq-host>/$rabbitmq-host/" beaver.conf
sed -i "s/<rabbitmq-vhost>/$rabbitmq-vhost/" beaver.conf
sed -i "s/<rabbitmq-username>/$rabbitmq-username/" beaver.conf
sed -i "s/<rabbitmq-password>/$rabbitmq-password/" beaver.conf
sed -i "s/<rabbitmq-exchange>/$rabbitmq-exchange/" beaver.conf