install_pure()
{
yum -y install gcc gcc-c++ autoconf automake ftp
yum -y install zlib zlib-devel openssl openssl--devel pcre pcre-devel

wget https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.46.tar.gz

tar zxvf pure-ftpd-1.0.46.tar.gz
cd pure-ftpd-1.0.46
./configure --prefix=/usr/local/pureftpd --with-language=simplified-chinese --with-everything
make && make install

sed -i 's|^# AltLog.*$|AltLog                       clf:/var/log/pureftpd.log|' /usr/local/pureftpd/etc/pure-ftpd.conf
sed -i 's|^# PIDFile.*$|PIDFile                      /var/run/pure-ftpd.pid|' /usr/local/pureftpd/etc/pure-ftpd.conf
sed -i 's|^# PassivePortRange.*$|PassivePortRange             30000 50000|' /usr/local/pureftpd/etc/pure-ftpd.conf
sed -i 's|^# PureDB.*pdb$|PureDB                       /usr/local/pureftpd/etc/pureftpd.pdb|' /usr/local/pureftpd/etc/pure-ftpd.conf
sed -i 's/^# CreateHomeDir.*yes$/CreateHomeDir  yes/' /usr/local/pureftpd/etc/pure-ftpd.conf
sed -i 's/^# IPV4Only.*yes$/IPV4Only                 yes/' /usr/local/pureftpd/etc/pure-ftpd.conf
sed -i 's/^# AnonymousCanCreateDirs.*$/AnonymousCanCreateDirs       yes/' /usr/local/pureftpd/etc/pure-ftpd.conf

ln -s /usr/local/pureftpd/sbin/pure-ftpd /usr/local/sbin/
ln -s /usr/local/pureftpd/bin/pure-pw /usr/local/bin/
groupadd ftpgroup
useradd -g ftpgroup  -d /dev/null -s /sbin/nologin ftpuser 
#新增用户
pure-pw useradd jjcc -u ftpuser  -d /var/ftp
pure-pw mkdb
chown -R ftpuser:ftpgroup  /var/ftp/
cat >/usr/lib/systemd/system/pure-ftpd.service <<-EOF
[Unit]
Description=Pure-FTPd FTP server
After=syslog.target network.target

[Service]
Type=forking
PIDFile=/var/run/pure-ftpd.pid
ExecStart=/usr/local/pureftpd/sbin/pure-ftpd /usr/local/pureftpd/etc/pure-ftpd.conf

[Install]
WantedBy=multi-user.target
EOF
systemctl start pure-ftpd
systemctl enable pure-ftpd
}





