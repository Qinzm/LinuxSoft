#!/bin/bash
softPath="/usr/local/src"
redisPort="16380"
dataPath="/data/redis"
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

install_redis()
{	
	yum install expect -y
	redispasswd=`mkpasswd -l 16`
	mkdir -p /var/log/redis/
	chown redis:redis -R /var/log/redis
	cd $softPath
	[ -f redis-4.0.9.tar.gz ] || wget http://download.redis.io/releases/redis-4.0.9.tar.gz
	tar -xzvf redis-*.tar.gz
	cd redis-*
	make && make install
	mkdir -p /etc/redis
	cp ./redis.conf /etc/redis/$redisPort.conf
	sed -i 's/^daemonize.*$/daemonize yes/'  /etc/redis/$redisPort.conf
	sed -i "s|^port.*$|port $redisPort|g"  /etc/redis/$redisPort.conf
	sed -i "s|^# requirepass.*$|requirepass $redispasswd|g" /etc/redis/$redisPort.conf
	sed -i 's/^# bind 127.0.0.1/bind 127.0.0.1/' /etc/redis/$redisPort.conf
	sed -i "s|^dir.*$|dir $dataPath|" /etc/redis/$redisPort.conf
	sed -i 's/appendonly no/appendonly yes/g'  /etc/redis/$redisPort.conf
	mkdir /var/log/redis
	chown -R redis.redis /var/log/redis
	sed -i 's|^logfile.*$|logfile "/var/log/redis/redis.log"|g' /etc/redis/$redisPort.conf
	sed -i "s|^pidfile /var/run/redis.*pid$|pidfile $dataPath/redis_$redisPort.pid|g" /etc/redis/$redisPort.conf
		
	cp ./utils/redis_init_script /etc/init.d/redis
	sed -i "s/^REDISPORT=.*$/REDISPORT=$redisPort/" /etc/init.d/redis
	sed -i "s|^PIDFILE=/var/run/redis_.*pid$|PIDFILE=$dataPath/redis_$redisPort.pid|" /etc/init.d/redis
	sed -i 's#$EXEC $CONF#su redis -s /bin/bash -c "$EXEC $CONF"#g' /etc/init.d/redis
	sed -i 's#$CLIEXEC -p $REDISPORT shutdown#su redis -s /bin/bash -c "$CLIEXEC -p $REDISPORT -a '${redispasswd}' shutdown"#g' /etc/init.d/redis
	#sysctl vm.overcommit_memory=1
	#echo never > /sys/kernel/mm/transparent_hugepage/enabled
	#echo "sysctl vm.overcommit_memory=1" >> /etc/rc.local
	#echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
	groupadd redis
	useradd -s /bin/nologin -r -g redis redis
	mkdir -p $dataPath
    chown redis:redis -R $dataPath

	/etc/init.d/redis start 
	echo "redis password is $redispasswd ..."
	echo "redis password is $redispasswd" >>/var/log/redis/redis.log
	
}

install_redis




