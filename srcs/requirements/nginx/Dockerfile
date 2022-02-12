# TODO change back to base image
# FROM debian:buster
FROM nginx:procps

# optional metadata for images in key-value form
# LABEL "maintainer"="Kasjan Chilarski"

# withouth 'apt update' first, i wasn't able to find or install anything
# Most Dockerfile commands like "RUN" create a layer, we want to combine commands
# to create fewer layers
# make 'ps' command available in container for debugging:
# RUN apt-get update && apt-get install -y nginx openssl procps

# Create self-signed certificate and place in locations referred to 
# in nginx.conf
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-private.key \
    -out /etc/ssl/certs/k-stz.42.fr.crt \
    -subj "/C=DE/CN=k-stz.42.fr"

# Copy nginx.conf from the Dockerfile directory into the container's
# absolute-path /etc/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# TODO find "infinite loop configuration"
# ENTRYPOINT nginx

# This is only documentation, that under this port the containers service will
# be available (which in the case of nginx are effectively configured in the nginx.conf file!)
EXPOSE 443/TCP

RUN mkdir -p /app/www && echo "Hello World!" > /app/www/index.html

CMD /bin/bash