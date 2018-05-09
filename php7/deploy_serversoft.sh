#!/bin/sh

softPath=`pwd`

confyum()
{
	yum -y install wget
	cd /etc/yum.repos.d/
	mkdir bak
	mv ./*.repo bak
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
	yum clean all && yum makecache
	yum -y install vim unzip  openssl-client gcc gcc-c++ ntp
}
confntpd()
{
	yum install -y ntp ntpdate
	cp /etc/ntp.conf /etc/ntp.conf.$(date  +%Y%m%d)
	sed -i 's/0.centos.pool.ntp.org iburst/ntp1.aliyun.com/g' /etc/ntp.conf
	sed -i 's/1.centos.pool.ntp.org iburst/ntp2.aliyun.com/g' /etc/ntp.conf
	sed -i 's/2.centos.pool.ntp.org iburst/ntp3.aliyun.com/g' /etc/ntp.conf
	sed -i 's/3.centos.pool.ntp.org iburst/ntp4.aliyun.com/g' /etc/ntp.conf
	chkconfig ntpd on
	/etc/init.d/ntpd start
}

confsshd()
{
	sed -i 's/#Port 22/Port 56000/' /etc/ssh/sshd_config;
	service sshd restart;
	ss -nat|grep 56000;
}

confsysctl()
{
  mv /etc/sysctl.conf /etc/sysctl.conf$(date  +%Y%m%d)
  cat >/etc/sysctl.conf <<-EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_timestamps = 1
net.ipv4.ip_local_port_range = 1024 65535
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.core.netdev_max_backlog = 30000
net.ipv4.tcp_no_metrics_save=1
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.nf_conntrack_max = 102400
net.ipv4.tcp_max_tw_buckets = 180000
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 6871947673
EOF
  sysctl -p
}

install_php()
{
yum groupinstall -y "Development tools" 
yum -y install wget libxml2 libxml2-devel openssl openssl-devel libcurl libcurl-devel libmcrypt libmcrypt-devel enca

softPath=`pwd`
cd $softPath
tar -xzvf php-5.5.38.tar.gz
cd php-*

./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--enable-zip \
--enable-ftp \
--with-zlib \
--with-mcrypt \
--with-openssl \
--with-curl \
--enable-mbstring  \
--enable-sockets  \
--with-mysql \
--with-mysqli \
--with-pdo-mysql \
--with-mcrypt \
--enable-xml

make && make install

cd $softPath/php-*/sapi/fpm
cp init.d.php-fpm.in  /etc/init.d/php-fpm

sed -i 's/@prefix@/\/usr\/local\/php/' /etc/init.d/php-fpm
sed -i 's/@exec_prefix@/${prefix}/' /etc/init.d/php-fpm
sed -i 's/@sbindir@/${prefix}\/sbin/' /etc/init.d/php-fpm
sed -i 's/@sysconfdir@/${prefix}\/etc/' /etc/init.d/php-fpm
sed -i 's/@localstatedir@/\/var/' /etc/init.d/php-fpm

chmod +x /etc/init.d/php-fpm
chkconfig --add /etc/init.d/php-fpm
chkconfig php-fpm on

cd $softPath/php-*/
cp php.ini-production /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/' /usr/local/php/etc/php.ini

cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
sed -i 's#user = nobody#user = www-data#' /usr/local/php/etc/php-fpm.conf
sed -i 's#group = nobody#group = www-data#' /usr/local/php/etc/php-fpm.conf

groupadd www-data
useradd -s /bin/nologin -r -g www-data www-data
echo 'export PATH=$PATH:/usr/local/php/bin' >> /etc/profile
usermod -a -G root www-data
source /etc/profile
	/etc/init.d/php-fpm start
	service php-fpm on
}

install_php_redis()
{
     cd $softPath
     [ -f redis-3.1.0.tgz ] || wget http://pecl.php.net/get/redis-3.1.0.tgz
     tar -xvzf redis-3.1.0.tgz
     cd redis-3.1.0
     /usr/local/php/bin/phpize
     ./configure --with-php-config=/usr/local/php/bin/php-config
     make install
     sed -i '$a extension=redis.so' /usr/local/php/etc/php.ini
}

install_ImageMagick()
{
	cd $softPath
	[ -f ImageMagick-6.9.7-3.tar.gz ] || wget ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.9.7-3.tar.gz
	tar -xvzf ImageMagick-6.9.7-3.tar.gz
	cd ImageMagick-6.9.7-3
	./configure --prefix=/usr/local/imagemagick
	make
	make install
}

install_php_imagick()
{
	cd $softPath
	[ -f imagick-3.4.3RC1.tgz ] || wget http://pecl.php.net/get/imagick-3.4.3RC1.tgz
	tar -xvzf imagick-3.4.3RC1.tgz
	cd imagick-3.4.3RC1
	 /usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config  --with-imagick=/usr/local/imagemagick
	
	make install
	sed -i '$a extension = imagick.so' /usr/local/php/etc/php.ini
}

install_nginx()
{
	yum install -y nginx
	chkconfig nginx on
	cp -f /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf$(date  +%Y%m%d)
	sed -i 's/listen.*]:80/#listen       [::]:80/' /etc/nginx/conf.d/default.conf
	sed -i 's/^user.*;/user www-data;/' /etc/nginx/nginx.conf
	useradd -s /bin/nologin -r -g www-data www-data
	chown www-data:www-data -R /var/lib/nginx 
	service nginx start
	service nginx on
}

install_php_mongo()
{
	cd $softPath
	[ -f mongo-1.6.14.tgz ]	|| wget http://pecl.php.net/get/mongo-1.6.14.tgz 
	tar -xvzf mongo-1.6.14.tgz
	cd mongo-1.6.14
	 /usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	
	make install
	sed -i '$a extension = mongo.so' /usr/local/php/etc/php.ini
	/etc/init.d/php-fpm restart
	check_phpext
}

install_php_play()
{
	cd $softPath
	[ -f play.1.6.1.tar.gz ] || exit 0
	tar -xvzf play.1.6.1.tar.gz
	cd play.1.6.1
	 /usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	
	make install
	sed -i '$a extension = play.so' /usr/local/php/etc/php.ini
	/etc/init.d/php-fpm restart 
	/etc/init.d/nginx restart
	check_phpext
}

install_php_gd()
{
	yum -y install libpng-devel  freetype libpng-devel libjpeg-devel freetype-devel
	cd $softPath/php-*
	cd ext/gd
	/usr/local/php/bin/phpize 
	./configure --with-png-dir --with-freetype-dir --with-jpeg-dir --with-gd --with-php-config=/usr/local/php/bin/php-config
	
	make install
        sed -i '$a extension = gd.so' /usr/local/php/etc/php.ini
        /etc/init.d/php-fpm restart
        /etc/init.d/nginx restart
        check_phpext
}

check_phpext()
{
source /etc/profile
cat >test.php<<-EOF
<?php
phpinfo();
?>
EOF

php test.php |grep "play support"
php test.php |grep "Redis Support"
php test.php |grep "MongoDB Support"
php test.php |grep "imagick module"
}

install_redis()
{	
	cd $softPath
	[ -f redis-3.2.9.tar.gz ] || wget http://download.redis.io/releases/redis-3.2.9.tar.gz
	tar -xzvf redis-3.2.9.tar.gz
	make 
	cd src
	make install
	mkdir -p /etc/redis
	cp ../redis.conf /etc/redis/6379.conf
	cp ../utils/redis_init_script /etc/init.d/
	sed -i 's/^daemonize.*$/daemonize yes/'  /etc/redis/6379.conf
	sed -i 's#^dir.*$#dir /var/lib/redis#'	/etc/redis/6379.conf
	sed -i 's/\$EXEC \$CONF/sudo -u redis \$EXEC \$CONF/' /etc/init.d/redis
	groupadd redis
	useradd -s /bin/nologin -r -g redis redis
	mkdir -p /var/lib/redis
        chown redis:redis -R /var/lib/redis
	chkconfif --add redis
        chkconfig redis on
	/etc/init.d/redis start 
}

install_serverenv()
{
	cd $softPath
yum groupinstall -y "Development tools"
yum -y install wget libxml2 libxml2-devel openssl openssl-devel libcurl libcurl-devel libmcrypt libmcrypt-devel libxml++ libxml++-devel
yum -y install ncurses-devel libtool-ltdl-devel bison-devel boost boost-devel boost-doc

	# install mysql-libs
	rpm -e --nodeps mysql-libs
	rpm -ivh mysql-community*
        rpm -ivh mysql-community-common-5.7.15-1.el6.x86_64.rpm
        rpm -ivh mysql-community-devel-5.7.15-1.el6.x86_64.rpm
        rpm -ivh mysql-community-client-5.7.15-1.el6.x86_64.rpm
        rpm -ivh mysql-community-libs-5.7.15-1.el6.x86_64.rpm	

	# install memcachedlib
	yum -y install libmemcached libmemcached-devel
}

install_libevent()
{
	cd $softPath
	[ -f libevent-release-1.4.15-stable.tar.gz ] || wget -O libevent-release-1.4.15-stable.tar.gz https://codeload.github.com/libevent/libevent/tar.gz/release-1.4.15-stable
	tar -zxvf libevent-release-1.4.15-stable.tar.gz
	cd libevent-release-1.4.15-stable
	./autogen.sh
	./configure --prefix=/usr
	make && make install
}

install_memcached()
{
	cd $softPath
	groupadd memcached
	useradd -r -g memcached memcached -s /sbin/nologin
	[ -f memcached-1.4.37.tar.gz ] || wget http://memcached.org/files/memcached-1.4.37.tar.gz
	tar -zxvf memcached-1.4.37.tar.gz
	cd memcached-*
	./configure --prefix=/usr/local/memcached --with-libevent=/usr
	make && make install
	ln -s /usr/local/memcached/bin/memcached /usr/bin/
	mkdir -p /var/run/memcached
	chown -R memcached:memcached /var/run/memcached

	# conf_memcached
cat >/etc/sysconfig/memcached<<-EOF
PORT="11211"
USER="memcached"
MAXCONN="10240"
CACHESIZE="2048"
OPTIONS=""
EOF

cat >/etc/init.d/memcached<<-EOF
#! /bin/sh
#
# chkconfig: - 55 45
# description:	The memcached daemon is a network memory cache service.
# processname: memcached
# config: /etc/sysconfig/memcached
# pidfile: /var/run/memcached/memcached.pid

# Standard LSB functions
#. /lib/lsb/init-functions

# Source function library.
. /etc/init.d/functions

PORT=11211
USER=memcached
MAXCONN=1024
CACHESIZE=64
OPTIONS=""

if [ -f /etc/sysconfig/memcached ];then 
	. /etc/sysconfig/memcached
fi

# Check that networking is up.
. /etc/sysconfig/network

if [ "\$NETWORKING" = "no" ]
then
	exit 0
fi

RETVAL=0
prog="memcached"
pidfile=\${PIDFILE-/var/run/memcached/memcached.pid}
lockfile=\${LOCKFILE-/var/lock/subsys/memcached}

start () {
	echo -n $"Starting \$prog: "
	# Ensure that /var/run/memcached has proper permissions
	if [ "`stat -c %U /var/run/memcached`" != "\$USER" ]; then
		chown \$USER /var/run/memcached
	fi

	daemon --pidfile \${pidfile} /usr/local/memcached/bin/memcached -d -p \$PORT -u \$USER  -m \$CACHESIZE -c \$MAXCONN -P \${pidfile} \$OPTIONS
	RETVAL=\$?
	echo
	[ \$RETVAL -eq 0 ] && touch \${lockfile}
}
stop () {
	echo -n $"Stopping \$prog: "
	killproc -p \${pidfile} /usr/bin/memcached
	RETVAL=\$?
	echo
	if [ \$RETVAL -eq 0 ] ; then
		rm -f \${lockfile} \${pidfile}
	fi
}

restart () {
        stop
        start
}


# See how we were called.
case "\$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
	status -p \${pidfile} memcached
	RETVAL=\$?
	;;
  restart|reload|force-reload)
	restart
	;;
  condrestart|try-restart)
	[ -f \${lockfile} ] && restart || :
	;;
  *)
	echo $"Usage: \$0 {start|stop|status|restart|reload|force-reload|condrestart|try-restart}"
	RETVAL=2
        ;;
esac

exit \$RETVAL
EOF

	chmod +x /etc/init.d/memcached
	/etc/init.d/memcached start	
}

startmemcached()
{
	chkconfig --add memcached
	chkconfig memcached on
	/etc/init.d/memcached start
}



while true
do
   echo "
	PHP 端
	PHP Nginx 运行用户 www-data
	PHP 默认安装扩展 imagick,redis,安装Nginx(YUM方式)
	Server 端
	Server 默认安装mysqllib,memcachelib
	Server 默认安装memcached(启动可选)
	
	[ confyum ]		配置yum源(非阿里云机器需要执行)
	[ confntpd ]		配置ntpd服务器(非阿里云机器需要执行)
	
	[ confsshd ] 		配置sshd端口到 56000
	[ confsysctl ]		配置内核参数
	[ install_php ]		安装PHP	环境
	[ install_php_mongo ] 	安装PHP mongo 扩展(连接mongo使用)
	[ install_php_play  ]	安装PHP play  扩展(连接小伴龙公众号使用)
	[ install_php_gd ]      安装PHP gd 扩展
	[ install_serverenv ]   安装Server 环境
	[ install_memcached ]   安装memcached
	[ startmemcached ]	启动memcached服务

	[X] 退出...
	
	"
read -p "输入安装命令 或者 X 退出:" tocommand
case $tocommand in
	confyum)
	confyum
	;;
	
	confntpd)
	confntpd
	;;
	
	confsshd)
	confsshd
	;;

	confsysctl)
	confsysctl
	;;
	
	install_php)
        install_php
	install_php_redis
	install_ImageMagick
	install_php_imagick
	install_nginx
	check_phpext
	;;
	
	install_php_mongo)
        install_php_mongo
        ;;

	install_php_play)
        install_php_play
        ;;
	
	install_php_gd)
	install_php_gd
	;;

        install_serverenv)
        install_serverenv
        ;;

        install_memcached)
	install_libevent
        install_memcached
        ;;
	
	startmemcached)
	startmemcached
	;;

	X)
	echo "退出...."
	exit 1
	;;
	*)
	echo "请输入执行命令 或者 X"
	continue
	;;
	esac
done
