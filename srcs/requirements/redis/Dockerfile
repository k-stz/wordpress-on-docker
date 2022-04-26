FROM debian:buster

RUN apt-get update
RUN apt-get -y install redis-server php7.3-redis
COPY redis.conf /etc/redis/redis.conf
#RUN CONFIG SET protected-mode no
RUN mkdir -p /var/www/html/
ENTRYPOINT ["redis-server"]

#RUN pwd
#RUN apt-get install tree
#RUN tree /var/www
#RUN /bin/bash