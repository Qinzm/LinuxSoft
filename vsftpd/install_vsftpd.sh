install_vsftpd()
{
yum -y install vsftpd
useradd vsftpd  -s /sbin/nologin
sed -i 's/^#anon_upload_enable=.*$/anon_upload_enable=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/^#anon_mkdir_write_enable=.*$/anon_mkdir_write_enable=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/^#ascii_upload_enable=.*$/ascii_upload_enable=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/^#ascii_download_enable=.*$/ascii_download_enable=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/^#chroot_local_user=.*$/chroot_local_user=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/^#chroot_list_enable=.*$/chroot_list_enable=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's|^#chroot_list_file=.*$|chroot_list_file=/etc/vsftpd/chroot_list|' /etc/vsftpd/vsftpd.conf
sed -i 's/^listen=.*$/listen=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/^listen_ipv6=.*$/listen_ipv6=NO/' /etc/vsftpd/vsftpd.conf
echo "guest_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "guest_username=vsftpd" >> /etc/vsftpd/vsftpd.conf
echo "user_config_dir=/etc/vsftpd/vuser_conf" >> /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf
touch /etc/vsftpd/chroot_list
echo "jjcc" >> /etc/vsftpd/vuser_passwd.txt
echo "jjcclife" >> /etc/vsftpd/vuser_passwd.txt
db_load -T -t hash -f /etc/vsftpd/vuser_passwd.txt /etc/vsftpd/vuser_passwd.db
sed -i '2,8s/^/#/' /etc/pam.d/vsftpd
echo "auth required pam_userdb.so db=/etc/vsftpd/vuser_passwd" >> /etc/pam.d/vsftpd
echo "account required pam_userdb.so db=/etc/vsftpd/vuser_passwd" >> /etc/pam.d/vsftpd
mkdir /etc/vsftpd/vuser_conf/
echo "local_root=/data/vsftpd" >> /etc/vsftpd/vuser_conf/jjcc
echo "write_enable=YES" >> /etc/vsftpd/vuser_conf/jjcc
mkdir -p /data/vsftpd
chmod -R 755 /data/vsftpd

echo "pasv_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=40000" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=40080" >> /etc/vsftpd/vsftpd.conf
echo "pasv_promiscuous=YES" >> /etc/vsftpd/vsftpd.conf

echo "anon_other_write_enable=YES" >> /etc/vsftpd/vsftpd.conf
echo "anon_root=/data/vsftpd" >> /etc/vsftpd/vsftpd.conf
echo "anon_umask=022" >> /etc/vsftpd/vsftpd.conf
mkdir /data/vsftpd/public
chmod -R 777 /data/vsftpd/public
}

[ -f /usr/sbin/vsftpd ] || install_vsftpd
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
