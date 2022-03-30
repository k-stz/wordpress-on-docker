# Purpose
This is an involved docker learning project. The goal ist to provide a wordpress+php-fpm website on nginx with a MariaDB backend through a single `docker-compose.yml`. 

To learn to configure and install this technology stack, all containers are build from the base `debian:buster` image.

# Structure Requirement
- The `Makefile` must build the whole project, calling `docker-compose.yml`.
- Each image must be named after its corresponding service. The Dockerfiles must be called in the docker-compose file

# Container requirements
- Forbidden to pull ready-made Docker images: build all the images using latest Alpine stable or Debian buster as the basis => I will use debian Buster
- Containers must be started running an infinite loop. This applies to any command used as entrypoint or entrypoint scripts. Hacks like tail -f, bash, sleep infinity, while true are forbidden. 
- `latest`-tag is proibited. 
- Restarting property: Containers have to restart in case of a crash!
- No password may be present in Dockerfiles instead use `.env`-files
- `.env`-files (used to  store environments Variables) must be located in the root of the `srcs` directory

Read about PID 1 and the best practices for writing Dockerfiles



# nginx Container
- with TLS 1.2 or TLS 1.3 **only**
- Only port 443 open into container (using TLSv1.2 or TLSv1.3)

Configuration File by default: is named nginx.conf and placed in the directory `/usr/local/nginx/conf`, `/etc/nginx`, or `/usr/local/etc/nginx`

nginx can be controlled like so:
`nginx -s [start|quit|reload|reopen]`
`start` doesn't work for me, but simply running `nginx` standalone, starts it.

## Website domain: `<username>.de`
To make your infrastructe accessible via https://k-stz.de simply
add the following in the /etc/hosts file:
```ini
127.0.0.1 k-stz.de
```
now writing it with `https` resolves to `localhost:443`.

## TLS 1.2 or TLS 1.3 only
In the nginx.conf in the server directive context we enable TLS with the `ssl_protocols TLSv.1.3` entry. 

But with a vanilla nginx you get the error `ERR_SSL_PROTOCOL_ERROR` instead of your website. Because we need to specify that the port we listen on uses ssl and enable ssl_protocols
```ini
server {
    listen 443 ssl;
    ssl_protocols TLSv1.2 TLSv1.3;
    ...
}
```

Now we get a generic `ERR_CONNECTION_CLOSED`, when inspecting the error.logs the problem is: no "ssl_certificate" is defined in server.
So lets define a certificate.

## TLS self-signed certificate
Source: https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04

To access our infrastructure via https://k-stz.de we need to use TLS (Transport layer security) and encrypt the traffic between the server and its clients with it. TLS is the successor to SSL (secure socket layer) and you will often read TLS/SSL, they both adhere to a common encyption standard.

Ideally, we want a certificate that was signed by a trusted authority: an authority that all conventional browsers trust, allowing our website to  be trusted by any (browser)client.

But because this is a small local project, we will use a self-signed certificate. Which is easy to create and appropriate for exclusively local website project. So how do we create the certificate?

TLS needs a public certificate and a private key. The private SSL key is kept secret on the server and will encrypt content sent to the client.

The public SSL certificate on the other hand is shared with anyone who requets the content. It can then decrypt the content signed by the private SSL key. 

We create the pair (SSL private key and public certificate) with the openssl command:

```s
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-private.key -out /etc/ssl/certs/k-stz.de.crt -subj "/C=DE/CN=k-stz.de"
```
Without the `-subj` option it would ask a few questions, which will show up on the certificate when checking it out in the browser (or the key directly in the command line using a query like: `openssl x509 -noout -text -in /etc/ssl/certs/k-stz.de.crt` ). Since it is just self-signed, it's content is inconsequential. Example output:
```
Country Name (2 letter code) [AU]:DE
State or Province Name (full name) [Some-State]:BW
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:k-stz.de.crt
Email Address []:keistzen@gmail.com
```

This creates and places both the private key in in the appropriate place on a Linux server: `/etc/ssl/private/nginx-private.key` and the SSL cerificate in `/etc/ssl/certs/k-stz.de.crt`, which must be named after the domain of your server. 

Finally we need to make the keys accessible by the nginx container. And point to the im in the nginx.conf in the server context:

```conf
server {
    listen 443 ssl;
    ...
    ssl_certificate /etc/ssl/certs/k-stz.de.crt
    ssl_certificate_key /etc/ssl/private/nginx-private.key
}
```

#### Convenient solution 
Finally I decided to use a convenient solution that is not practical in the real world. We will simply create the certificates on the fly everytime we build the nginx container by running:

```Dockerfile
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-private.key -out /etc/ssl/certs/k-stz.42.fr.crt -subj "/C=DE/CN=k-stz.de"
```


# Wordpress Volume
nginx needs files to be owned by the `www-data` user and since the files
need to be on a volume, we can create them on the hosting vm:

TODO: check if uid is always 33
`useradd -u 33 www-data`



TODO: sudo chown -R www-data: /var/www/html/sample.c



# wordpress
`apt-get install wordpress -y`

om

## `php-fpm` 
PHP-FPM is a Fast CGI process manager (FPM)


# MariaDB 
requirements
- Volume that contains DB at `/home/<login>/data`
- restart in case of crash
- two users: non-admin, admin
- port: 3306, available on
apt-get install mariadb-server

```conf
# MariaDB setup
ROOT_PASSWORD=XXXXXXXX
MARIADB_USER=XXXXXXXX
MARIADB_PASSWORD=XXXXXXXX
```

now `service mysql` shows its available

TODO:
Create users: dbroot (the admin) and a second user

create volume:
`docker volume create db`

then bind it locally with `docker run -v:db mariadb:test

# Volumes requirements:
Will be available in the `/home/<login>/data` folder of the host machine using Docker. 

- for WordPress database
- for WordPress website files



# Network requirements:
- to make things simpler we configure the domain name `<login>.de` to point to the local IP address
=> in /etc/hosts simply add the entry: 
```ini
127.0.0.1 username.de 
```
- `docker-network` that establishes the connection between the containers
- "host or `--link` or `links` is forbidden
- network line must be present in the `docker-compose.yml`




# Install packages:
- docker (contains `docker compose` command)


# Docker

```ini
# List images
docker images
# remove image
docker rmi <docker-id>
# List exited, running, stopped containers
docker ps -a
# delete all containers
docker rm $(docker ps -a -q)
```
## Container
Is a highly isolated process in terms of multiple namespaces of: users, processes, storage, filesystem-view. A containerized Process can be fooled into thinking it has its own users with UID, runs as root and can access the whole filesystem when in fact it is just run by the kernel in a subset of all three of these features: its users map to entirely different users, it isn't root to the rest of the OS and it has a fake subset view of the Filesystem and can't even change the "real" Filesystem.
This isolation buys us abstraction of the environment in which a process runs, such that we can run processes in containers and then move those containers to different computers and OS and they still run the same. In principle at least, there are some quirks, like the kernel having to support all the features needed by the container fundamentally, but overall that's the idea.

## Docker Image
An image is the basis from which a Container can be made. An Debian base image is a an object accessible by the docker-cli from which debian-based containers can be build. 

To find the image you want use `docker search` or go to dockerhub.com. Dockerhub is the place where the `docker`-cli fetches images by default - the so called "registry".

## Docker debian buster image
Debian is a distribution and buster is the codename of Version 10 of Debian (Debian 11 is called bullseye). To the the latest stable version we use:

`debian pull debian:buster`
Here debian is the baseimage and `:buster` is the tag.

## Run a Container
To run an interactive bash-shell in a container use:
`docker run --rm -it debian:buster /bin/bash`

`--rm` will remove the Container once it stops. Else we can easily waste a lot of space with finished containers.
`--it`: `-i` interactive: taking STDIN; `-t` allocates a tty so you get prompt

This is great for getting a feel for what the container can do and debug your `Dockerfile`. For example you could first try to interactively install nginx in their and then write the `Dockerfile` once your comfortable.

## Container published Ports
To expose network service via a port in the container we use the `-p` public option:
`docker run --rm -it -p 5000:443 nginx:stable /bin/bash`
This exposes the internal containers Port 443 to outside the container to port 5000. Such that visiting "localhost:5000" will access the containers service on the internal port 443.
Now whether a service in the container actually listens on that port is unrelated. That's why it should be documented where on which port a given container offers what service.

In the Dockerfile you will find the `EXPOSE 443` statement, but that is pure documentation. It has to be, else their would be a coupling between a container and the host it runs on via fixed host ports. Imagine you want to run multiple containers all wanting to publish to the same port on a common host.

## Build a Container
Use a `Dockerfile` to define a container and build it running `docker build -t my-image-name .` in the same directory. 