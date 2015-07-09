# docker-librenms
Docker image for LibreNMS

## About

This is a generic docker container for [LibreNMS](http://www.librenms.org/).

## Basic commands to run the container

    docker run \
        -d \
        -p 80:80 \
        -e DB_HOST=db \
        -e DB_NAME=librenms \
        -e DB_USER=librenms \
        -e DB_PASS=secret \
        -e BASE_URL=http://localhost \
        --link my-database-container:db \
        -v /my/persistent/directory/logs:/opt/librenms/logs \
        -v /my/persistent/directory/rrd:/opt/librenms/rrd \
        --name librenms \
        jarischaefer/docker-librenms

## SSL

Mount another directory containing ssl.key, ssl.crt and optionally ssl.ocsp.crt to enable https.
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
        --link my-database-container:db \
        -v /my/persistent/directory/logs:/opt/librenms/logs \
        -v /my/persistent/directory/rrd:/opt/librenms/rrd \
        -v /my/persistent/directory/ssl:/etc/nginx/ssl:ro \
        --name librenms \
        jarischaefer/docker-librenms

## Environment config

The following keys can be passed directly via the -e switch:

* DB_HOST
* DB_USER
* DB_PASS
* DB_NAME
* MEMCACHED_ENABLE
* MEMCACHED_HOST
* MEMCACHED_PORT
* BASE_URL
* UPDATE

## Custom config

To configure more advanced settings, you may use another mount.
The following example shows how to ignore some common interface names.

    docker run \
        -d \
        -p 80:80 \
        -p 443:443 \
        -e DB_HOST=db \
        -e DB_NAME=librenms \
        -e DB_USER=librenms \
        -e DB_PASS=secret \
        -e BASE_URL=https://localhost \
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

$config['bad_if_regexp'][] = '/^docker[0-9]+$/';
$config['bad_if_regexp'][] = '/^lxcbr[0-9]+$/';
$config['bad_if_regexp'][] = '/^veth.*$/';
$config['bad_if_regexp'][] = '/^virbr.*$/';
$config['bad_if_regexp'][] = '/^lo$/';
$config['bad_if_regexp'][] = '/^macvtap.*$/';
$config['bad_if_regexp'][] = '/gre.*$/';
$config['bad_if_regexp'][] = '/tun[0-9]+$/';
```

The start script automatically appends the contents of config.custom.php to config.php.

## Running in prodution

You should probably use a reverse proxy like [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) for production.
Alerting via email may be somewhat difficult to setup right.
It is recommended you [link](https://docs.docker.com/userguide/dockerlinks/) an SMTP server and use that for your alerts.

## License

This project is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).

LibreNMS has its own license, this license only covers the Docker part.