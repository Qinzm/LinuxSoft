#!/bin/sh
softPath=`pwd` 
softPath="/usr/local/src"
installPath="/usr/local/php7"
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

install_php()
{
yum groupinstall -y "Development tools" 
yum -y install wget libxml2 libxml2-devel openssl openssl-devel libcurl libcurl-devel libmcrypt libmcrypt-devel enca

cd $softPath
tar -xzvf php-7.*.tar.gz
cd php-*

./configure --prefix=$installPath \
--with-config-file-path=$installPath/etc \
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

cd $softPath/php-*/
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm

chmod +x /etc/init.d/php-fpm
chkconfig --add /etc/init.d/php-fpm
chkconfig php-fpm on

cd $softPath/php-*/

cp php.ini-production $installPath/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/' $installPath/etc/php.ini


cd  $installPath
cp ./etc/php-fpm.conf.default ./etc/php-fpm.conf
cp ./etc/php-fpm.d/www.conf.default ./etc/php-fpm.d/www.conf
sed -i 's#;error_log#error_log#' $installPath/etc/php-fpm.conf

sed -i 's#user = nobody#user = php-fpm#' $installPath/etc/php-fpm.d/www.conf
sed -i 's#group = nobody#group = php-fpm#' $installPath/etc/php-fpm.d/www.conf

groupadd php-fpm
useradd -s /bin/nologin -r -g php-fpm php-fpm
echo "export PATH=$PATH:$installPath/bin:$installPath/sbin/" >> /etc/profile
usermod -a -G root php-fpm
source /etc/profile
	/etc/init.d/php-fpm start
}

install_php_redis()
{
cd $softPath
wget http://pecl.php.net/get/redis-3.1.6.tgz -O phpredis.tgz
tar zxvf phpredis.tar.gz
cd phpredis*
$installPath/bin/phpize
./configure -with-php-config=$installPath/bin/php-config 
make && make install
echo "extension=redis.so" >> $installPath/etc/php.ini
}


install_php_gd()
{
	yum -y install libpng-devel  freetype libpng-devel libjpeg-devel freetype-devel
	cd $softPath/php-*
	cd ext/gd
	$installPath/bin/phpize 
	./configure --with-png-dir --with-freetype-dir --with-jpeg-dir --with-gd --with-php-config=$installPath/bin/php-config
	make && make install
    sed -i '$a extension = gd.so' $installPath/etc/php.ini
    /etc/init.d/php-fpm restart
}


install_php_fileinfo()
{

	cd $softPath/php-*
	cd ext/fileinfo
	$installPath/bin/phpize 
	./configure  --with-php-config=$installPath/bin/php-config
	make && make install
    sed -i '$a extension=fileinfo.so' $installPath/etc/php.ini
    /etc/init.d/php-fpm restart
}

confyum
install_php
install_phpize
install_php_gd
install_php_fileinfo