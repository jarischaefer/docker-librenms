# docker-librenms
Docker image for LibreNMS

## About

This is a generic docker container for [LibreNMS](http://www.librenms.org/).

The container runs nginx 1.11+ with HTTP/2 support and PHP 7.0 FPM
with [OPCache](http://php.net/manual/en/book.opcache.php) and [rrdcached](https://oss.oetiker.ch/rrdtool/doc/rrdcached.en.html)  for maximum
performance.

## Basic commands to run the container

	docker run \
		-d \
		-p 80:80 \
		-e DB_HOST=db \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=http://localhost \
		-e POLLERS=16 \
		--link my-database-container:db \
		-v /my/persistent/directory/logs:/opt/librenms/logs \
		-v /my/persistent/directory/rrd:/opt/librenms/rrd \
		--name librenms \
		jarischaefer/docker-librenms

## Initial setup

### Database configuration

If you don't have a MySQL server setup either in Docker or elsewhere then you can create a docker container [here](MYSQL.md).

You should read the [LibreNMS installation docs](http://docs.librenms.org/Installation/Installation-Ubuntu-1604-Nginx/)
for the latest instructions regarding database setup.

As of November 2016, the following is still a requirement:

> NOTE: Whilst we are working on ensuring LibreNMS is compatible with MySQL strict mode, for now, please disable this after mysql is installed.

### Database schema

Make sure the database exists before running these commands.

Creating the tables:

	docker exec librenms sh -c "cd /opt/librenms && php /opt/librenms/build-base.php"

Creating an initial admin user:

	docker exec librenms php /opt/librenms/adduser.php admin admin 10 test@example.com

## SSL

Mount another directory containing ssl.key, ssl.crt and optionally ssl.ocsp.crt to enable HTTPS.
You'll also have to change BASE_URL.

	docker run \
		-d \
		-p 80:80 \
		-p 443:443 \
		-e DB_HOST=db \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=https://localhost \
		-e POLLERS=16 \
		--link my-database-container:db \
		-v /my/persistent/directory/logs:/opt/librenms/logs \
		-v /my/persistent/directory/rrd:/opt/librenms/rrd \
		-v /my/persistent/directory/ssl:/etc/nginx/ssl:ro \
		--name librenms \
		jarischaefer/docker-librenms

## Environment config

The following keys can be passed directly via the -e switch:

* BASE_URL
* DB_HOST
* DB_PORT
* DB_USER
* DB_PASS
* DB_NAME
* MEMCACHED_ENABLE
* MEMCACHED_HOST
* MEMCACHED_PORT
* POLLERS
* DISABLE_IPV6
* TZ

## Custom config

To configure more advanced settings, you may use another mount.
The following example demonstrates how temporary or otherwise undesired
interfaces may be ignored.

	docker run \
		-d \
		-p 80:80 \
		-p 443:443 \
		-e DB_HOST=db \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=https://localhost \
		-e POLLERS=16 \
		--link my-database-container:db \
		-v /my/persistent/directory/logs:/opt/librenms/logs \
		-v /my/persistent/directory/rrd:/opt/librenms/rrd \
		-v /my/persistent/directory/ssl:/etc/nginx/ssl:ro \
		-v /my/persistent/directory/config.custom.php:/opt/librenms/config.custom.php:ro \
		--name librenms \
		jarischaefer/docker-librenms

Notice the line -v /my/persistent/directory/config.custom.php:/opt/librenms/config.custom.php:ro.
The example config contains the following:

```
// config.custom.php

$config['bad_if_regexp'][] = '/^docker[\w]+$/';
$config['bad_if_regexp'][] = '/^lxcbr[0-9]+$/';
$config['bad_if_regexp'][] = '/^veth.*$/';
$config['bad_if_regexp'][] = '/^virbr.*$/';
$config['bad_if_regexp'][] = '/^lo$/';
$config['bad_if_regexp'][] = '/^macvtap.*$/';
$config['bad_if_regexp'][] = '/gre.*$/';
$config['bad_if_regexp'][] = '/tun[0-9]+$/';
```

The start script automatically appends the contents of config.custom.php to config.php.

## Running in production

The commands above are purely for illustrative purposes.
You should customize them to fit your environment.

Also, please note that...

* Alerting via email is supported via SMTP only.
* Publicly accessible installations should be put behind
[jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) or
similar proxies for better access control and security hardening.

## License

This project is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).

LibreNMS has its own license, this license only covers the Docker part.
