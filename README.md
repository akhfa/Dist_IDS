# Dist_IDS
Repository ini berisi tentang script yang melakukan configurasi dalam instalasi sistem untuk melindungi sistem terdistribusi.

## Penjelasan setiap folder
* Config: Berisi konfigurasi yang dibutuhkan oleh masing-masing subsistem. Hasil akhir file config akan sesuai dengan apa yang dimasukkan oleh user ketika menjalankan script instalasi.
* Patterns: Berisi file pattern dari reguler expression yang digunakan sistem.
* Repo: Berisi file repository untuk instalasi perangkat lunak yang dibutuhkan oleh sistem.
* Script: Berisi semua script instalasi sistem
 
## Cara melakukan instalasi sistem
1. Login ke server message broker
2. Jalankan script/core/install_rabbitmq.sh
3. Buatlah user dan virtual host yang akan dipakai sistem.
4. Masuk ke server parser
5. Jalankan script/core/add_parser.sh
6. Masuk ke server management
7. Jalankan script/core/add_management.sh
8. Masuk ke masing-masing node pada setiap cluster. Pastikan hostname dari masing-masing node unik. Contoh: clusterName-hostname
9. Jalankan script/core/add_cluster.sh
 
### Note
Script instalasi akan melakukan install node dengan file .php yang rawan SQL injection. Sebelum digunakan untuk melindungi cluster, pastikan script add_cluster.sh sudah dimodifikasi sehingga tidak melakukan instalasi LAMP dan script php.