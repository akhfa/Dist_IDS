# Deskripsi:
#	Digunakan untuk membuat cluster baru maupun node baru

# Format:
#	./add_cluster.sh <exchange name> <queue name>

# Keterangan:
#       exchange        = cluster
#       queue           = node

#!/bin/sh
wget https://raw.githubusercontent.com/akhfa/ta/master/script/add_exchange_queue.sh
chmod +x add_exchange_queue.sh
./add_exchange_queue.sh $1 $2
