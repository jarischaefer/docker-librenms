# docker-librenms
Docker image for LibreNMS

## About

This is a generic docker container for [LibreNMS](http://www.librenms.org/).

The container runs nginx 1.13+ with HTTP/2 support and PHP 7.2 FPM
with [OPCache](http://php.net/manual/en/book.opcache.php) and
[rrdcached](https://oss.oetiker.ch/rrdtool/doc/rrdcached.en.html) for maximum performance.

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
		-e TZ=UTC \
		--link my-database-container:db \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		--name librenms \
		jarischaefer/docker-librenms

## Initial setup

### Database configuration

If you don't have a MySQL server setup either in Docker or elsewhere
then you can create a docker container [here](MYSQL.md).

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
		-e TZ=UTC \
		--link my-database-container:db \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		-v /data/ssl:/etc/nginx/ssl:ro \
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
* DISABLE_IPV6
* ENABLE_SYSLOG
* MEMCACHED_ENABLE
* MEMCACHED_HOST
* MEMCACHED_PORT
* POLLERS
* TZ
* DISCOVERY_ENABLE
* DISCOVERY_THREADS
* DAILY_ENABLE
* ALERTS_ENABLE
* POLL_BILLING_ENABLE
* BILLING_CALCULATE_ENABLE
* CHECK_SERVICES_ENABLE
* POLLERS_ENABLE
* RRDCACHED_ENABLE
* RRDCACHED_CONNECT
* RRDCACHED_LISTEN
* NGINX_ENABLE
* PHPFPM_ENABLE
* SNMP_SCAN_ENABLE
* SKIP_CHOWN

## Custom config

You may apply custom configuration by mounting files matching
*.php in /opt/librenms/conf.d.

Notice config.interfaces.php below:

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
		-e TZ=UTC \
		--link my-database-container:db \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		-v /data/ssl:/etc/nginx/ssl:ro \
		-v /data/config.interfaces.php:/opt/librenms/conf.d/config.interfaces.php \
		--name librenms \
		jarischaefer/docker-librenms

config.interfaces.php:
```
<?php

$config['bad_if_regexp'][] = '/^docker[-\w].*$/';
$config['bad_if_regexp'][] = '/^lxcbr[0-9]+$/';
$config['bad_if_regexp'][] = '/^veth.*$/';
$config['bad_if_regexp'][] = '/^virbr.*$/';
$config['bad_if_regexp'][] = '/^lo$/';
$config['bad_if_regexp'][] = '/^macvtap.*$/';
$config['bad_if_regexp'][] = '/gre.*$/';
$config['bad_if_regexp'][] = '/tun[0-9]+$/';
```

## Disabling cron jobs or the local rrdcached instance

If you plan to use this container for a distributed LibreNMS installation, you may want to disable some of
the [default cron jobs](https://github.com/jarischaefer/docker-librenms/blob/master/files/etc/cron.d/librenms),
or the local rrdcached, nginx and php-fpm services. You could also increase the number of `discovery-wrapper.py`
threads.

	docker run \
		-d \
		-p 80:80 \
		-e DB_HOST=db \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=http://localhost \
		-e POLLERS=16 \
		-e TZ=UTC \
		-e DISCOVERY_THREADS=2 \
		-e DAILY_ENABLE=false \
		-e ALERTS_ENABLE=false \
		-e CHECK_SERVICES_ENABLE=false \
		-e RRDCACHED_ENABLE=false \
		-e NGINX_ENABLE=false \
		-e PHPFPM_ENABLE=false \
		--link my-database-container:db \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		--name librenms \
		jarischaefer/docker-librenms

## Executing commands inside the container

Make sure you `source` the environment variables from /etc/librenms_environment
prior to executing commands inside the container.

This is an example demonstrating how to run the validation script.

	su - librenms
	source /etc/librenms_environment
	cd /opt/librenms
	php validate.php

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
