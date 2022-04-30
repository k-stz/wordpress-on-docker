#!/bin/bash


adduser \
	-D \
	-G $WP_USER \
	-h /home/$WP_USER \
	-s /bin/false \
	-u 82 \
	$WP_USER

