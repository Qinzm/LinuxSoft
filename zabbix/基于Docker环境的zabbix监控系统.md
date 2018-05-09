##基于Docker环境的zabbix监控系统搭建示例
1.1 Docker的安装
	
	yum install docker‐ce
	
配置Docker加速器
	
	vi /etc/docker/daemon.json
	{
	"registry-mirrors":["https://jknij3yj.mirror.aliyuncs.com"]
	}
	
启动并设置为开机启动

	systemctl start docker
	systemctl disable docker

1.2 拉取镜像
	
docker官方仓库有许多现成的镜像供大家使用，docker search 命令可以查找自己需要的各种镜像，
出于安全性和自身应用的需求，建议只是用官方提供的镜像来构建自己的镜像。

	docker search centos:7

	INDEX       NAME                                         DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
	docker.io   docker.io/centos                             The official build of CentOS.                   4194      [OK]       
	docker.io   docker.io/ansible/centos7-ansible            Ansible on Centos7                              108                  [OK]
	docker.io   docker.io/jdeathe/centos-ssh                 CentOS-6 6.9 x86_64 / CentOS-7 7.4.1708 x8...   94                   [OK]
	docker.io   docker.io/consol/centos-xfce-vnc             Centos container with "headless" VNC sessi...   52                   [OK]
	docker.io   docker.io/imagine10255/centos6-lnmp-php56    centos6-lnmp-php56                              40                   [OK]
	docker.io   docker.io/tutum/centos                       Simple CentOS docker image with SSH access      38                   
	docker.io   docker.io/gluster/gluster-centos             Official GlusterFS Image [ CentOS-7 +  Glu...   26                   [OK]

	docker pull centos:7

	Trying to pull repository docker.io/library/centos ... 
	7: Pulling from docker.io/library/centos
	469cfcc7a4b3: Pull complete 
	Digest: sha256:989b936d56b1ace20ddf855a301741e52abca38286382cba7f44443210e96d16
	Status: Downloaded newer image for docker.io/centos:7

2 zabbix&mysql镜像的构建

zabbix官方发布有基于docker的镜像：https://hub.docker.com/r/zabbix/zabbix-server-mysql/，但是有系统汉化、数据库配置等其他方面的需求，这里自动构建的镜像。

2.1构建前准备
	centos7是使用systemd管理服务的，docker基础镜像是精简版的，缺少对应的Unit单元，这里采用编译安装的方式.

	构建文件如下：
	.
	├── Dockerfile
	├── entrypoint.sh
	├── msyh.ttf
	├── mysql-5.6.36.tar.gz
	└── zabbix-3.4.8.tar.gz

	msyh.ttf 微软雅黑字体文件用于系统汉化，可以在windows系统上找到：C:\Windows\Fonts
	mysql-5.6.36.tar.gz 用作数据存储，下载地址为http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz
	zabbix-3.4.8.tar.gz 使用最新版zabbix3.4,下载地址为https://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.4.8/zabbix-3.4.8.tar.gz
	Dockerfile 文件是docker构建镜像需要的配置文件，需要自己配置。
	entrypoint.sh 文件是镜像配置容器启动的文件。镜像的配置可以在Dockerfile里面，entrypoint.sh是非必须的

2.2 Dockfile文件

	FROM centos
	MAINTAINER qinzhiming
	WORKDIR /root
	ENV LANG en_US.UTF‐8
	ENV MYSQL_ROOT_PASSWORD ''
	RUN \cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	RUN yum ‐y install libaio perl perl‐devel 'perl(Data::Dumper)'
	COPY entrypoint.sh /root/entrypoint.sh
	COPY mysql‐5.6.10‐linux‐glibc2.5‐x86_64.tar.gz /root/
	COPY zabbix‐3.2.3.tar.gz /root/
	COPY msyh.ttf /root/
	RUN mkdir -p /usr/local/mysql/data
	VOLUME /usr/local/mysql/data
	EXPOSE 3306
	ENTRYPOINT sh entrypoint.sh

2.3 entrypoint.sh容器配置脚本及容器启动入口文件
	
	
	