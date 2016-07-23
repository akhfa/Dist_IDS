# Deskripsi:
#	Digunakan untuk membuat cluster baru maupun node baru

# Format:
#	./add_cluster.sh <exchange name> <queue name>

# Keterangan:
#       exchange        = cluster
#       queue           = node

#!/bin/sh

# Install JDK
wget https://raw.githubusercontent.com/akhfa/ta/master/script/install-jdk.sh
chmod +x install-jdk.sh
./install-jdk.sh

# Install Logstash
https://raw.githubusercontent.com/akhfa/ta/master/script/install-logstash.sh
chmod +x install-logstash.sh
./install-logstash.sh

# Install exchange (jika belum ada) dan queue untuk node ini
wget https://raw.githubusercontent.com/akhfa/ta/master/script/add_exchange_queue.sh
chmod +x add_exchange_queue.sh
./add_exchange_queue.sh $1 $2
