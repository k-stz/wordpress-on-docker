#!/usr/bin/env bash

service nginx start

/usr/sbin/php-fpm7.3 -F -R
