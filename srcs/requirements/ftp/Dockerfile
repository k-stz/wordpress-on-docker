FROM debian:buster

RUN apt-get update; 
RUN apt-get install -y vsftpd;

# Create user with empty password
#RUN useradd bob -m; passwd -d bob;

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY vsftpd.conf /etc/vsftpd.conf
VOLUME /var/www/html

ENTRYPOINT ["docker-entrypoint.sh"]