#!/bin/bash


useradd -m bob
WP_USER_PASSWORD=123
echo "bob:${WP_USER_PASSWORD}" | chpasswd
echo "root:${WP_USER_PASSWORD}" | chpasswd

# allow root login
sed -i s/root/#root/g /etc/ftpusers


# Start ftp server in foreground
vsftpd

