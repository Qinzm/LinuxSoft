#!/bin/bash 
softPath="/usr/local/src"
installPath="/usr/local/nginx"
confyum()
{
	yum -y install wget
	cd /etc/yum.repos.d/
	mkdir bak
	mv ./*.repo bak
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
	yum clean all && yum makecache
	yum -y install vim unzip  openssl-client 
}

install()
{
yum -y install gcc gcc-c++ make automake pcre pcre-devel zlib zlib-devel open openssl-devel
wget http://nginx.org/download/nginx-1.10.3.tar.gz
tar zxvf nginx-1.10.3.tar.gz
cd nginx*

./configure --prefix=$installPath \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-pcre 
make && make install
}

confyum
install
