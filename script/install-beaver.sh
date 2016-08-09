#!/bin/sh

if [$1 == ""]; then
	echo "rabbitmq host:"
	input -e rabbitmqHost
	echo "rabbitmq vhost:"
	input -e rabbitmqVhost
	echo "rabbitmq username:"
	input -e rabbitmqUsername
	echo "rabbitmq password:"
	input -e rabbitmqPassword
	echo "rabbitmq exchange:"
	input -e rabbitmqExchange
else
	rabbitmqHost = $1
	rabbitmqVhost = $2
	rabbitmqUsername = $3
	rabbitmqPassword = $4
	rabbitmqExchange = $5
fi

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install beaver==36.2.0
mkdir /etc/beaver

wget -O https://raw.githubusercontent.com/akhfa/ta/master/config/cluster/beaver.conf

sed -i "s/<rabbitmqHost>/$rabbitmq-host/" beaver.conf
sed -i "s/<rabbitmqVhost>/$rabbitmq-vhost/" beaver.conf
sed -i "s/<rabbitmqUsername>/$rabbitmq-username/" beaver.conf
sed -i "s/<rabbitmqPassword>/$rabbitmq-password/" beaver.conf
sed -i "s/<rabbitmqExchange>/$rabbitmq-exchange/" beaver.conf