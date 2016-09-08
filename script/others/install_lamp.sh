#!/bin/bash
yum install httpd -y
systemctl start httpd.service
systemctl enable httpd.service
yum install mariadb-server mariadb -y
systemctl start mariadb
systemctl enable mariadb.service
yum install php php-mysql -y
systemctl restart httpd.service

yum install epel-release -y
yum install phpmyadmin -y
sed -i '17d' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '17d' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '17iRequire all granted' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '33d' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '33d' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '33iRequire all granted' /etc/httpd/conf.d/phpMyAdmin.conf
systemctl restart httpd.service