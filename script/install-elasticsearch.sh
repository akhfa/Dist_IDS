# Deskripsi:
#	Instalasi elasticsearch dan konfigurasi yang dibutuhkan

#!/bin/sh
sudo rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
wget https://raw.githubusercontent.com/akhfa/ta/master/repo/elasticsearch.repo
mv elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
sudo yum -y install elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch