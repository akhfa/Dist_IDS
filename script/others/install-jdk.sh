#!/bin/sh
echo "Installing java...."
cd /opt
wget -q --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz"
tar xzf jdk-8u91-linux-x64.tar.gz
cd /opt/jdk1.8.0_91/
alternatives --install /usr/bin/java java /opt/jdk1.8.0_91/bin/java 2
alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_91/bin/jar 2
alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_91/bin/javac 2
alternatives --set jar /opt/jdk1.8.0_91/bin/jar
alternatives --set javac /opt/jdk1.8.0_91/bin/javac
ln -s /opt/jdk1.8.0_91 /opt/jdk-latest
echo "JAVA_HOME=/opt/jdk-latest" >> ~/.bash_profile
source ~/.bash_profile
echo "Install java selesai!"