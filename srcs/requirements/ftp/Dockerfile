FROM debian:buster

RUN apt-get update; 
RUN apt-get install vsftpd;

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh