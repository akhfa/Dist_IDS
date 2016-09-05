# Deskripsi:
#	Instalasi elasticsearch dan konfigurasi yang dibutuhkan

#!/bin/sh
echo "Install elasticsearch..."
rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/repo/elasticsearch.repo
mv elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
yum install elasticsearch -y
echo "Install elasticsearch selesai!"