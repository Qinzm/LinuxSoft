install_mysql()
{
yum -y install perl-Data-Dumper  libaio libaio-devel
softPath="/"
installPath="/usr/local/mysql"
datapath="/var/lib/mysql"
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
sed -i '/^socket.*$/a\innodb_file_per_table=1' /etc/my.cnf
sed -i '/^socket.*$/a\character-set-server=utf8' /etc/my.cnf
ln -s /usr/local/mysql/bin/mysql /usr/bin
ln -s /usr/local/mysql/bin/mysqladmin /usr/bin
ln -s /usr/local/mysql/bin/mysqldump /usr/bin
ln -s /usr/local/mysql/mysql.sock /tmp/mysql.sock
/etc/init.d/mysqld start
mysql -uroot -e "create database zabbix character set utf8;"
mysql -uroot -e  "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
mysql -uroot -e  "flush privileges;"
cd /
}


install_zabbix()
{
yum -y install gcc gcc‐c++ make automake mysql-devel curl-devel  autoconf libtool
yum -y install net-snmp-devel libxml2-devel libcurl-deve libevent libevent-devel
[ -f zabbix-3.4.8.tar.gz  ] || wget https://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.4.8/zabbix-3.4.8.tar.gz
tar zxvf zabbix-3.4.8.tar.gz 
cd zabbix-3.4.8
./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
make && make install

mysql -uzabbix -pzabbix zabbix </zabbix-3.4.8/database/mysql/schema.sql;
mysql -uzabbix -pzabbix zabbix </zabbix-3.4.8/database/mysql/images.sql;
mysql -uzabbix -pzabbix zabbix </zabbix-3.4.8/database/mysql/data.sql;

groupadd zabbix
useradd -r -g zabbix zabbix
chown -R zabbix:zabbix /usr/local/zabbix
mkdir -p /usr/local/zabbix/logs
chown zabbix:zabbix /usr/local/zabbix/logs
mkdir -p /usr/lib/zabbix/alertscripts
mkdir -p /usr/lib/zabbix/externalscripts
chown -R zabbix:zabbix /usr/lib/zabbix

cp misc/init.d/fedora/core/zabbix* /etc/init.d/
chmod 755 /etc/init.d/zabbix_server
chmod 755 /etc/init.d/zabbix_agentd

cp misc/init.d/fedora/core/zabbix* /etc/init.d/
chmod 755 /etc/init.d/zabbix_server
chmod 755 /etc/init.d/zabbix_agentd

sed -i 's|BASEDIR=.*$|BASEDIR=/usr/local/zabbix|g' /etc/init.d/zabbix_server
sed -i 's|BASEDIR=.*$|BASEDIR=/usr/local/zabbix|g' /etc/init.d/zabbix_agent
sed -i 's|PIDFILE=.*$|PIDFILE=/usr/local/zabbix/logs/$BINARY_NAME.pid|g' /etc/init.d/zabbix_server
sed -i 's|PIDFILE=.*$|PIDFILE=/usr/local/zabbix/logs/$BINARY_NAME.pid|g' /etc/init.d/zabbix_agent

sed -i 's|^LogFile=.*zabbix_server.log|LogFile=/usr/local/zabbix/logs/zabbix_server.log|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# PidFile=/tmp/zabbix_server.pid|PidFile=/tmp/zabbix_server.pid|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# DBHost=localhost|DBHost=localhost|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# DBPassword=|DBPassword=zabbix|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# DBSocket=.*sock|DBSocket=/tmp/mysql.sock|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# DBPort=3306|DBPort=3306|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# StartPollers=5|StartPollers=5|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# CacheSize=8M$|CacheSize=256M|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# SNMPTrapperFile=/tmp/zabbix_traps.*$|SNMPTrapperFile=/var/log/snmptt/snmptrap.log|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's|^# AlertScriptsPath=.*alertscripts$|AlertScriptsPath=/usr/lib/zabbix/alertscripts|g' /usr/local/zabbix/etc/zabbix_server.conf 
sed -i 's|^# ExternalScripts=.*externalscripts$|ExternalScripts=/usr/lib/zabbix/externalscripts|g' /usr/local/zabbix/etc/zabbix_server.conf
sed -i 's/^Hostname=.*/Hostname=localhost/g' /usr/local/zabbix/etc/zabbix_agentd.conf
cp -rf frontends/php /var/www/html/zabbix
chown -R apache.apache /var/www/html/zabbix
cp /msyh.ttf /var/www/html/zabbix/fonts/
sed -i "s/DejaVuSans/msyh/g" /var/www/html/zabbix/include/defines.inc.php
cd /usr/share/i18n/charmaps
gunzip GB2312.gz
localedef -f GB2312 -i zh_CN /usr/lib/locale/zh_CN.GB2312
}





install_php()
{
yum groupinstall -y "Development tools" 
yum -y install wget libxml2 libxml2-devel openssl openssl-devel libcurl libcurl-devel libmcrypt libmcrypt-devel enca 
yum -y install httpd httpd-devel
[ -f php-5.5.38.tar.bz2 ] || wget http://cn2.php.net/distributions/php-5.5.38.tar.bz2
tar -xvf php-5.5.38.tar.bz2
cd php-5.5.38
installPath=/usr/local/php

./configure --prefix=$installPath \
--with-config-file-path=$installPath/etc \
--with-apxs2=/usr/bin/apxs \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--enable-fpm \
--enable-zip \
--enable-ftp \
--enable-bcmath \
--with-zlib \
--with-openssl \
--with-curl \
--enable-mbstring  \
--enable-sockets  \
--with-pdo-mysql \
--with-mysqli \
--with-pdo-mysql \
--enable-exif \
--with-gettext \
--enable-pcntl \
--enable-shmop \
--enable-soap \
--enable-sysvsem \
--with-xmlrpc \
--enable-xml

make && make install

cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

cp php.ini-production $installPath/etc/php.ini
sed -i sed -i 's#^;date.timezone.*$#date.timezone =Asia/shanghai#' $installPath/etc/php.ini
sed -i 's/^max_execution_time.*$/max_execution_time = 300/g' $installPath/etc/php.ini
sed -i 's/^post_max_size.*$/post_max_size=16M/g' $installPath/etc/php.ini
sed -i 's/^max_input_time.*$/max_input_time=300/' $installPath/etc/php.ini
cp $installPath/etc/php-fpm.conf.default $installPath/etc/php-fpm.conf
echo "listen = 127.0.0.1:9000" >> $installPath/etc/php-fpm.conf
/etc/init.d/php-fpm start
#sed -i "/AddType application\/x-gzip .gz .tgz/a\    LoadModule php5_module        /usr/lib64/httpd/modules/libphp5.so" /etc/httpd/conf/httpd.conf
sed -i "/AddType application\/x-gzip .gz .tgz/a\    DirectoryIndex index.php index.html" /etc/httpd/conf/httpd.conf
sed -i "/AddType application\/x-gzip .gz .tgz/a\    AddType application/x-httpd-php-source .phps" /etc/httpd/conf/httpd.conf
sed -i "/AddType application\/x-gzip .gz .tgz/a\    AddType application\/x-httpd-php .php" /etc/httpd/conf/httpd.conf
cd /
}

install_php_gd()
{
	yum -y install libpng-devel  freetype libpng-devel libjpeg-devel freetype-devel
	installPath=/usr/local/php
	cd /php-5.5.38
	cd ext/gd
	$installPath/bin/phpize 
	./configure --with-png-dir --with-freetype-dir --with-jpeg-dir --with-gd --with-php-config=$installPath/bin/php-config
	make && make install
    sed -i '$a extension = gd.so' $installPath/etc/php.ini
    /etc/init.d/php-fpm restart
	cd /
}

install_php_ldap()
{
	yum -y install openldap openldap-devel 
	installPath=/usr/local/php
	cd /php-5.5.38
	cd ext/ldap 
	cp -frp /usr/lib64/libldap* /usr/lib/
	$installPath/bin/phpize 
	./configure  --with-php-config=$installPath/bin/php-config
	make && make install
    sed -i '$a extension = ldap.so' $installPath/etc/php.ini
    /etc/init.d/php-fpm restart
	cd /
}



