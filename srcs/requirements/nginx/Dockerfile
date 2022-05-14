FROM debian:buster
# FROM nginx:procps

# optional metadata for images in key-value form
# LABEL "maintainer"="Kasjan Chilarski"

# withouth 'apt update' first, i wasn't able to find or install anything
# Most Dockerfile commands like "RUN" create a layer, we want to combine commands
# to create fewer layers
# make 'ps' command available in container for debugging:
RUN apt-get update && apt-get install -y nginx openssl procps

# Create self-signed certificate and place in locations referred to 
# in nginx.conf
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-private.key \
    -out /etc/ssl/certs/k-stz.de.crt \
    -subj "/C=DE/CN=k-stz.de"

# Copy nginx.conf from the Dockerfile directory into the container's
# absolute-path /etc/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY common.conf /etc/nginx/conf.d/
COPY wordpress.conf /etc/nginx/conf.d/
COPY k-stz.de.conf /etc/nginx/conf.d/

# This is only documentation, that under this port the containers service will
# be available (which in the case of nginx are effectively configured in the nginx.conf file!)
EXPOSE 443/TCP

RUN mkdir -p /app/www && echo "Hello World!" > /app/www/index.html

# From the offical nginx image: creates a symbolic link from the nginx log files to the 
# stdout and stderr device. This in effect writes all logs to the foreground. This allows
# "docker logs <container>" to read these logs, instead of having to attach to the running
# container!
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir -p /var/www/adminer && chown root:root /var/www/adminer;

# maybe now i dont need the mkdir -p ... above?
VOLUME /var/www/html

# Starts nginx in foreground. If on container startup there is no process 
# in the foreground it immediately exits
CMD ["nginx", "-g", "daemon off;"]