#!/bin/sh

echo "install pip dan beaver"

if [ "$1" == "" ]; then
	read -p "rabbitmq host: " -e rabbitmqHost
	read -p "rabbitmq vhost:" -e rabbitmqVhost
	read -p "rabbitmq username:" -e rabbitmqUsername
	read -p "rabbitmq password:" -e rabbitmqPassword
	read -p "rabbitmq exchange:" -e rabbitmqExchange
	read -p "rabbitmq queue:" -e rabbitmqQueue
	read -p "cluster name: " -e clusterName
	read -p "log location: " -e logLocation
else
	rabbitmqHost=$1
	rabbitmqVhost=$2
	rabbitmqUsername=$3
	rabbitmqPassword=$4
	rabbitmqExchange=$5
	rabbitmqQueue=$6
	clusterName=$7
	logLocation=$8
fi

wget -q https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install beaver==36.2.0
mkdir /etc/beaver

wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/cluster/beaver.conf

sed -i "s/<rabbitmq-host>/$rabbitmqHost/" beaver.conf
sed -i "s/<rabbitmq-vhost>/$rabbitmqVhost/" beaver.conf
sed -i "s/<rabbitmq-username>/$rabbitmqUsername/" beaver.conf
sed -i "s/<rabbitmq-password>/$rabbitmqPassword/" beaver.conf
sed -i "s/<rabbitmq-exchange>/$rabbitmqExchange/" beaver.conf
sed -i "s/<rabbitmq-queue>/$rabbitmqQueue/" beaver.conf
sed -i "s/<cluster-name>/$clusterName/" beaver.conf
sed -i "s,<log-location>,'$logLocation'," beaver.conf

sed -i '412d'
sed -i '412d'
sed -i "s/fieldkeys/fields[0::2]/" /usr/lib64/python2.7/site-packages/beaver/config.py
sed -i "s/fieldvalues/fields[1::2]/" /usr/lib64/python2.7/site-packages/beaver/config.py

mv beaver.conf /etc/beaver/

rm -f get-pip.py

echo "selesai install beaver"