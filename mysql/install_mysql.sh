#!/bin/bash

softPath="/usr/local/src"
installPath="/usr/local/mysql"
datapath="/data/mysql"

confyum()
{
	yum -y install wget
	cd /etc/yum.repos.d/
	mkdir bak
	mv ./*.repo bak
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum clean all && yum makecache
	yum -y install vim unzip  openssl-client gcc gcc-c++ ntp
}

install_mysql()
{
yum -y install perl-Data-Dumper  libaio libaio-devel
cd $softPath
[ -f mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz ] || wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz
tar zxvf mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz 
mv mysql-5.6.36-linux-glibc2.5-x86_64 $installPath
useradd mysql -s /sbin/nologin
mkdir -p $datapath
chown -R mysql.mysql $datapath
chown -R mysql.mysql $installPath
cd $installPath
./scripts/mysql_install_db --user=mysql --datadir=$datapath
cp support-files/mysql.server /etc/init.d/mysqld
sed -i "s#^basedir.*$=#basedir=$installPath#g" /etc/init.d/mysqld
sed -i "s#^datadir=.*$#datadir=$datapath#g" /etc/init.d/mysqld
[ -f /etc/my.cnf ] && mv /etc/my.cnf /etc/my$(date  '+%Y%m%d%H%M').cnfbak
cp support-files/my-default.cnf /etc/my.cnf
sed -i "s|^# basedir =.*$|basedir = $installPath|g" /etc/my.cnf
sed -i "s|^# datadir =.*$|datadir = $datapath|g" /etc/my.cnf
sed -i "s/^# port =.*$/port = 3306/g" /etc/my.cnf
sed -i  "s|^# server_id =.*$|server_id = 1|g" /etc/my.cnf
sed -i  "s|^# socket =.*$|socket = $installPath/mysql.sock|g" /etc/my.cnf
sed -i '/^socket.*$/a\character-set-server=utf8' /etc/my.cnf
sed -i '/^socket.*$/a\innodb_file_per_table=1' /etc/my.cnf
ln -s $installPath/bin/mysql /usr/bin
ln -s $installPath/bin/mysqladmin /usr/bin
ln -s $installPath/bin/mysqldump /usr/bin
ln -s $installPath/mysql.sock /tmp/mysql.sock
/etc/init.d/mysqld start


}

confyum
install_mysql