## RDS云数据库恢复到本地 ##

1.安装mysql5.6

	rpm -ivh http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm && yum -y install mysql-server mysql

2.下载阿里云的解压脚本
	
	cd && wget http://oss.aliyuncs.com/aliyunecs/rds_backup_extract.sh

3.从阿里云下载RDS,上传到根目录或者直接wegt下载，具体下载备份文件参考，[RDS备份文件恢复到自建数据库](https://help.aliyun.com/knowledge_detail/41817.html)中步骤
	
	cd 
	
	mkdir -p /db/mysql

	sh rds_backup_extract.sh -f /root/hins4377595_data_20180412164949.tar.gz -C /db/mysql

4.修改目录权限

	chown mysql:mysql -R /db/mysql

5.修改配置文件

	vi /db/mysql/my.cnf
	
	#其中skip-grant是取消忽略用户密码
	[mysqld]
	datadir = /db/mysql
	port = 3306
	server_id = 3
	socket = /db/mysql/mysqld.sock
	max_allowed_packet=32M
	log-error = /db/mysql/error.log
	default-storage-engine=INNODB

6.启动mysql
	
	/usr/bin/mysqld_safe --defaults-file=/db/mysql/my.cnf &

7.登录修改密码，查询数据


	mysql -h127.0.0.1 –uroot 

	>use mysql;
	>update user set password=password('123456') where user='root';
	>update user set host='%' where user='root' && host='127.0.0.1';
	>flush privileges;

注意本教程与官方方法不同:

	1、没有安装percona-Xtrabackup数据恢复软件进行数据恢复

	2、数据库root用户是忽略掉的