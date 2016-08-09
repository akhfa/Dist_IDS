#!/bin/sh

if [$1 == ""]; then
	read -p "rabbitmq host: " -e rabbitmqHost
	read -p "rabbitmq vhost:" -e rabbitmqVhost
	read -p "rabbitmq username:" -e rabbitmqUsername
	read -p "rabbitmq password:" -e rabbitmqPassword
	read -p "rabbitmq exchange:" -e rabbitmqExchange
else
	rabbitmqHost=$1
	rabbitmqVhost=$2
	rabbitmqUsername=$3
	rabbitmqPassword=$4
	rabbitmqExchange=$5
fi

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install beaver==36.2.0
mkdir /etc/beaver

wget https://raw.githubusercontent.com/akhfa/ta/master/config/cluster/beaver.conf

sed -i "s/<rabbitmq-host>/$rabbitmqHost/" beaver.conf
sed -i "s/<rabbitmq-vhost>/$rabbitmqVhost/" beaver.conf
sed -i "s/<rabbitmq-username>/$rabbitmqUsername/" beaver.conf
sed -i "s/<rabbitmq-password>/$rabbitmqPassword/" beaver.conf
sed -i "s/<rabbitmq-exchange>/$rabbitmqExchange/" beaver.conf

mv beaver.conf /etc/beaver/