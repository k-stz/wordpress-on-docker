FROM debian:buster

RUN apt-get update -y ; \
 	apt-get upgrade -y ; \
 	apt-get install adminer php7.3-fpm -y;

COPY www.conf /etc/php/7.3/fpm/pool.d/www.conf

RUN mkdir /run/php; touch /run/php/php7.3-fpm.pid;
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# CMD /usr/sbin/php-fpm7.3 -F -R

ENTRYPOINT ["docker-entrypoint.sh"]