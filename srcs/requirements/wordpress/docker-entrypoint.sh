#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$1" == apache2* ]] || [ "$1" = 'php-fpm' ]; then
	uid="$(id -u)"
	gid="$(id -g)"
	if [ "$uid" = '0' ]; then
		case "$1" in
			apache2*)
				user="${APACHE_RUN_USER:-www-data}"
				group="${APACHE_RUN_GROUP:-www-data}"

				# strip off any '#' symbol ('#1000' is valid syntax for Apache)
				pound='#'
				user="${user#$pound}"
				group="${group#$pound}"
				;;
			*) # php-fpm
				user='www-data'
				group='www-data'
				;;
		esac
	else
		user="$uid"
		group="$gid"
	fi

	if [ ! -e index.php ] && [ ! -e wp-includes/version.php ]; then
		# if the directory exists and WordPress doesn't appear to be installed AND the permissions of it are root:root, let's chown it (likely a Docker-created directory)
		if [ "$uid" = '0' ] && [ "$(stat -c '%u:%g' .)" = '0:0' ]; then
			chown "$user:$group" .
		fi

		echo >&2 "WordPress not found in $PWD - copying now..."
		if [ -n "$(find -mindepth 1 -maxdepth 1 -not -name wp-content)" ]; then
			echo >&2 "WARNING: $PWD is not empty! (copying anyhow)"
		fi
		sourceTarArgs=(
			--create
			--file -
			--directory /usr/src/wordpress
			--owner "$user" --group "$group"
		)
		targetTarArgs=(
			--extract
			--file -
		)
		if [ "$uid" != '0' ]; then
			# avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
			targetTarArgs+=( --no-overwrite-dir )
		fi
		# loop over "pluggable" content in the source, and if it already exists in the destination, skip it
		# https://github.com/docker-library/wordpress/issues/506 ("wp-content" persisted, "akismet" updated, WordPress container restarted/recreated, "akismet" downgraded)
		for contentPath in \
			/usr/src/wordpress/.htaccess \
			/usr/src/wordpress/wp-content/*/*/ \
		; do
			contentPath="${contentPath%/}"
			[ -e "$contentPath" ] || continue
			contentPath="${contentPath#/usr/src/wordpress/}" # "wp-content/plugins/akismet", etc.
			if [ -e "$PWD/$contentPath" ]; then
				echo >&2 "WARNING: '$PWD/$contentPath' exists! (not copying the WordPress version)"
				sourceTarArgs+=( --exclude "./$contentPath" )
			fi
		done
		tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
		echo >&2 "Complete! WordPress has been successfully copied to $PWD"
	fi

	wpEnvs=( "${!WORDPRESS_@}" )
	if [ ! -s wp-config.php ] && [ "${#wpEnvs[@]}" -gt 0 ]; then
		for wpConfigDocker in \
			wp-config-docker.php \
			/usr/src/wordpress/wp-config-docker.php \
		; do
			if [ -s "$wpConfigDocker" ]; then
				echo >&2 "No 'wp-config.php' found in $PWD, but 'WORDPRESS_...' variables supplied; copying '$wpConfigDocker' (${wpEnvs[*]})"
				# using "awk" to replace all instances of "put your unique phrase here" with a properly unique string (for AUTH_KEY and friends to have safe defaults if they aren't specified with environment variables)
				awk '
					/put your unique phrase here/ {
						cmd = "head -c1m /dev/urandom | sha1sum | cut -d\\  -f1"
						cmd | getline str
						close(cmd)
						gsub("put your unique phrase here", str)
					}
					{ print }
				' "$wpConfigDocker" > wp-config.php
				if [ "$uid" = '0' ]; then
					# attempt to ensure that wp-config.php is owned by the run user
					# could be on a filesystem that doesn't allow chown (like some NFS setups)
					chown "$user:$group" wp-config.php || true
				fi
				break
			fi
		done
	fi
fi


# hardcoded install wordpress website, to skip installation dialog on startup
wp core install --title="Meine Seite" --admin_user=${WORDPRESS_DB_USER} --admin_password=${WORDPRESS_DB_PASSWORD} --admin_email=me@example.com --url=localhost --allow-root
# simple test if if admin_user is the only user, otherwise the command fails and we get an endless container restarting loop
result=$(wp user list --allow-root | wc -l)
if [ $result -lt 3 ]; then
	wp user create $WP_USER $WP_USER_MAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root
fi
wp plugin install redis-cache --activate --allow-root
wp redis enable --force --allow-root

# hacky solution: generate drop-in for redis-object-cache and overwrite it with ours
wp redis update-dropin --allow-root
cp /tmp/object-cache.php /var/www/html/wp-content/object-cache.php

cp /tmp/object-cache.php /var/www/html/wp-content

echo <<END
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', '6379');
define('WP_REDIS_MAXTTL', '900');
define('WP_REDIS_KEY_SALT', 'saaalt');
END
>> /var/www/html/wp-config.php
exec "$@"

# maybe need to do:
# apk add --no-cache pcre-dev $PHPIZE_DEPS \
        # && pecl install redis \
        # && docker-php-ext-enable redis.so