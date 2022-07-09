docker-librenms
---

***Docker image for LibreNMS***

---
> :warning: **This document refers to the master branch and does not necessarily correspond to the version that you are running.**
It is recommended to extract the readme from your preferred release's source code archive.
Releases are listed on the [Releases page](https://github.com/jarischaefer/docker-librenms/releases).

---

# About

docker-librenms is a customizable Docker image for [LibreNMS](http://www.librenms.org/) based on Ubuntu.

The container runs nginx 1.18+ with HTTP/2 support and PHP 8.1 FPM with [OPCache](http://php.net/manual/en/book.opcache.php)
and [rrdcached](https://oss.oetiker.ch/rrdtool/doc/rrdcached.en.html) for maximum performance.

> :warning: ARM is not supported currently, see [here](https://github.com/jarischaefer/docker-librenms/issues/114) for more details.

---

# Initial setup

## 1.1. Generating an encryption key

You must first generate a unique encryption key.

**Generating the key**

	docker run --rm jarischaefer/docker-librenms generate_key

**Output example**

	base64:Q0+ZV56/5Uwz79vsvS4ZfwQFOty3e9DJEouEy+IXvz8=

> :warning: Make sure you keep the key secret, because anyone in possession of it can decrypt sensitive data.

## 1.2. Passing the encryption key

There are currently two methods to pass the encryption key to LibreNMS. Make sure to include the full key (including `base64:`)
regardless of the method used.

### 1.2.1. Passing the key directly via environment variable

The key can be passed via the `APP_KEY` environment variable in the `docker run` command.

**Example**

The following command is incomplete and only illustrates passing an environment variable:

	docker run -e APP_KEY=base64:Q0+ZV56/5Uwz79vsvS4ZfwQFOty3e9DJEouEy+IXvz8= jarischaefer/docker-librenms

### 1.2.2. Passing the key via a secret file

Alternatively, you may use the `APP_KEY_FILE` environment variable and mount the secret as a file inside the container.
You must first create the file on the host and only then start the container (otherwise Docker creates and mounts a directory instead of a file).

**Example**

The following command is incomplete and only illustrates passing an environment variable and mounting a file:

	docker run -e APP_KEY_FILE=/mount/secret_key -v /path/on/host/secret_key:/mount/secret_key

## 2.1. Database - Prerequisites

If you don't have a MySQL server setup either in Docker or elsewhere then you can create a docker container [here](MYSQL.md).

You should read the [LibreNMS installation docs](https://docs.librenms.org/Installation/Install-LibreNMS/)
for the latest instructions regarding database setup.

As of July 2020, the following settings are required (should apply to both MariaDB and MySQL):
```
innodb_file_per_table=1
lower_case_table_names=0
```

## 2.2. Database - Creating LibreNMS tables

You should have a MySQL server running at this point. Make sure the database, user and permissions exist before running the commands.

Next, follow the instructions for [running the container](#running-the-container).
Once the container is up and running, you may use the following commands to populate the database and create an admin user.

**Creating the tables**

	docker exec librenms setup_database

## 3.1. LibreNMS - Adding users

**Creating an initial admin user**

	docker exec librenms create_admin

This creates a user with the following properties:

* User: admin
* Password: admin
* Level: 10
* E-Mail: admin@example.com

**Creating a custom user**

	docker exec librenms create_user user password level email
	
Example:

	docker exec librenms create_user test test 10 test@example.com

---

# Running the container

The examples below do not cover all of the available configuration options, check the appropriate section in the docs for a complete list.

## Linked database container

In the example below the linked container is named `my-database-container` and its alias inside the container is `database`.
Make sure `my-database-container` matches the MySQL container's name and `DB_HOST` matches its alias inside the container if you intend
to modify it.

	docker run \
		-d \
		-h librenms \
		-p 80:80 \
		-e APP_KEY=the_secret_key_you_have_generated \
		-e DB_HOST=database \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=http://localhost \
		--link my-database-container:database \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		--name librenms \
		jarischaefer/docker-librenms

## Remote database

	docker run \
		-d \
		-h librenms \
		-p 80:80 \
		-e APP_KEY=the_secret_key_you_have_generated \
		-e DB_HOST=x.x.x.x \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=http://localhost \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		--name librenms \
		jarischaefer/docker-librenms

## SSL

Mount another directory containing `ssl.key`, `ssl.crt` and optionally `ssl.ocsp.crt` to enable HTTPS.
You'll also have to change `BASE_URL`.

	docker run \
		-d \
		-h librenms \
		-p 80:80 \
		-p 443:443 \
		-e APP_KEY=the_secret_key_you_have_generated \
		-e DB_HOST=database \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=https://localhost \
		--link my-database-container:database \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		-v /data/ssl:/etc/nginx/ssl:ro \
		--name librenms \
		jarischaefer/docker-librenms

---

# Updating the container

Updating an existing installation requires updating both the image and the database.

## 1.1. Image update - Pulling a new version

1. Pick a release from the [Releases page](https://github.com/jarischaefer/docker-librenms/releases)
2. Run `docker pull jarischaefer/docker-librenms:{release}`
3. Restart your container using the new version
4. Follow the steps for database updates

## 1.2. Database update

Automatic database updates are the most convenient solution for single-container setups.

## 1.2.1. Manual database updates (safe)

Run `docker exec librenms setup_database`.

## 1.2.2. Automatic database updates (potentially unsafe)

If you would like to update the database automatically on startup, you may pass `DAILY_ON_STARTUP=true`.
Keep in mind that restarting more than one container simultaneously could result in concurrency issues and damage your database.

The LibreNMS implementation (as of October 2018) uses a distributed lock via memcache to avoid this scenario.
Therefore, if all containers share the same memcache instance, concurrent restarts would be safe.

---

# Configuration

> :warning: The container must be stopped, removed and subsequently restarted in order for configuration changes to take effect.

The following keys can be passed directly via the `-e` switch:

## Basic configuration

|Key                     |Default                               |Description
|------------------------|--------------------------------------|------------------------------
|APP_KEY                 |                                      |Secret encryption key
|APP_KEY_FILE            |                                      |Secret encryption key via file/secret
|BASE_URL                |                                      |Base URL for LibreNMS (e.g. http://192.168.0.1:8080)
|DB_HOST                 |                                      |MySQL IP or hostname
|DB_PORT                 |3306                                  |MySQL port
|DB_NAME                 |                                      |MySQL database name
|DB_USER                 |                                      |MySQL user
|DB_PASS                 |                                      |MySQL password
|DB_PASS_FILE            |                                      |MySQL password via secret
|TZ                      |UTC                                   |Timezone (e.g. Europe/Zurich)
|PUID                    |                                      |User ID
|PGID                    |                                      |Group ID
|PHP_FPM_WORKERS_MIN     |1                                     |Minimum number of PHP-FPM workers
|PHP_FPM_WORKERS_MAX     |4                                     |Maximum number of PHP-FPM workers

## Enabling/disabling container features

|Key                     |Default                               |Description
|------------------------|--------------------------------------|------------------------------
|DISABLE_IPV6            |false                                 |Disable nginx IPv6 socket
|MEMCACHED_ENABLE        |false                                 |Enable memcached
|MEMCACHED_HOST          |                                      |memcached IP or hostname
|MEMCACHED_PORT          |11211                                 |memcached port
|NGINX_ENABLE            |true                                  |Enable nginx
|PHPFPM_ENABLE           |true                                  |Enable PHP-FPM
|RRDCACHED_ENABLE        |true                                  |Enable rrdcached
|RRDCACHED_CONNECT       |unix:/var/run/rrdcached/rrdcached.sock|rrdcached TCP or unix socket where LibreNMS connects to
|RRDCACHED_LISTEN        |unix:/var/run/rrdcached/rrdcached.sock|rrdcached TCP or unix socket where rrdcached listens on
|SKIP_CHOWN              |false                                 |Disable (slow) `chown`ing of files at startup (might help with network storage)
|SNMPTRAPD_ENABLE        |false                                 |Enable [SNMP Trap Handler](https://docs.librenms.org/Extensions/SNMP-Trap-Handler/)
|SNMPTRAPD_MIBS          |IF-MIB                                |Passed to snmptrapd via `-m`
|SNMPTRAPD_MIBDIRS       |/opt/librenms/mibs                    |Passed to snmptrapd via `-M`
|LIBRENMS_SERVICE_ENABLE |false                                 |Enable librenms-service.py
|LIBRENMS_SERVICE_OPTS   |""                                    |Options for librenms-service.py (e.g. `-v`)

## Enabling/disabling LibreNMS features

|Key                     |Default                               |Description
|------------------------|--------------------------------------|------------------------------
|ALERTS_ENABLE           |true                                  |Enable LibreNMS alerts
|BILLING_CALCULATE_ENABLE|true                                  |Enable LibreNMS billing calculation
|CHECK_SERVICES_ENABLE   |true                                  |Enable LibreNMS service checks
|DAILY_ENABLE            |true                                  |Enable LibreNMS daily script
|DAILY_ON_STARTUP        |false                                 |Enable LibreNMS daily script on startup
|DISCOVERY_ENABLE        |true                                  |Enable LibreNMS discovery
|DISCOVERY_THREADS       |1                                     |Number of threads for discovery
|ENABLE_SYSLOG           |false                                 |Enable LibreNMS syslog ([see here](#syslog))
|POLL_BILLING_ENABLE     |true                                  |Enable LibreNMS billing polling
|POLLERS_ENABLE          |true                                  |Enable LibreNMS polling
|POLLERS                 |8                                     |Number of LibreNMS pollers
|POLLERS_CRON            |*/5 * * * *                           |Cron schedule for pollers
|SNMP_SCAN_ENABLE        |false                                 |Enable cron for [snmp-scan](https://docs.librenms.org/#Extensions/Auto-Discovery/#snmp-scan)
|SNMP_SCAN_CRON          |0 0 * * *                             |Cron schedule for snmp-scan
|WEATHERMAP_ENABLE       |false                                 |Enable cron for [weathermap](https://github.com/librenms-plugins/Weathermap) ([see here](#Weathermap))
|WEATHERMAP_CRON         |*/5 * * * *                           |Cron schedule for weathermap

## Custom configuration

You may apply custom configuration by mounting files matching
`*.php` in `/opt/librenms/conf.d`.

In the example below `/data/config.interfaces.php` on the host
is mounted inside the container at `/opt/librenms/conf.d/config.interfaces.php`.

	docker run \
		-d \
		-h librenms \
		-p 80:80 \
		-p 443:443 \
		-e APP_KEY=the_secret_key_you_have_generated \
		-e DB_HOST=database \
		-e DB_NAME=librenms \
		-e DB_USER=librenms \
		-e DB_PASS=secret \
		-e BASE_URL=https://localhost \
		--link my-database-container:database \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		-v /data/ssl:/etc/nginx/ssl:ro \
		-v /data/config.interfaces.php:/opt/librenms/conf.d/config.interfaces.php \
		--name librenms \
		jarischaefer/docker-librenms

**config.interfaces.php**
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
		-h librenms \
		-p 80:80 \
		-e APP_KEY=the_secret_key_you_have_generated \
		-e DB_HOST=database \
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
		--link my-database-container:database \
		-v /data/logs:/opt/librenms/logs \
		-v /data/rrd:/opt/librenms/rrd \
		--name librenms \
		jarischaefer/docker-librenms

## Custom Nagios plugins

Nagios plugins are stored in `/usr/lib/nagios/plugins`. Choose one of the options below if you would like to add new plugins.
See the [corresponding issue](https://github.com/jarischaefer/docker-librenms/issues/125) for more information.

**Option 1 (recommended)**

1. Mount a new directory to `/mount/nagios_plugins`. Example (using Docker CLI): `-v /nagios_plugins:/mount/nagios_plugins`
2. Copy the new plugins to `/nagios_plugins` on the host
3. Restart the container and verify that the files exist: `docker exec librenms ls -al /usr/lib/nagios/plugins`

The container will automatically symlink the contents of `/mount/nagios_plugins` to `/usr/lib/nagios/plugins`.

**Example**

```
docker exec librenms ls -al /usr/lib/nagios/plugins/check_xyz

lrwxrwxrwx 1 root root 31 Jan 21 22:19 /usr/lib/nagios/plugins/check_xyz -> /mount/nagios_plugins/check_xyz
```

**Option 2**

Make sure the plugin (file) exists on the host before starting the container (Docker creates a directory on startup by default).
Each plugin must be mounted individually (`-v` for Docker CLI), for example: `-v /nagios_plugins/check_xyz:/usr/lib/nagios/plugins/check_xyz` 

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

---

# syslog

These are instructions for the [LibreNMS syslog extension](https://docs.librenms.org/#Extensions/Syslog/).

* Add `-e ENABLE_SYSLOG=true` to your docker run command
* Add `-p 514:514` and `-p 514:514/udp` to your docker run command
* Configure the remote host whose logs should be gathered (rsyslog example)
  * Create /etc/rsyslog.d/60-librenms.conf
  * Add `*.* @example.com:514`

Unfortunately, due to the way Docker works (more specifically, its network modes), the devices and IP addresses
visible in LibreNMS may not be what one would expect. Instead of displaying the host's real IP address,
it is possible that an internal address such as `172.17.0.1` is observed. More information regarding this behavior
can be found in the [corresponding issue](https://github.com/jarischaefer/docker-librenms/issues/120).

# Weathermap

These are instructions for the [LibreNMS weathermap plugin](https://github.com/librenms-plugins/Weathermap).

The weathermap plugin requires additional mounts to persist its data.
* `/opt/librenms/html/plugins/Weathermap/configs` for the configs
* `/opt/librenms/html/plugins/Weathermap/output` for the generated data

Make sure you set *Output Image Filename* to `output/example.png` and
*Output HTML Filename* to `output/example.html` in the *Map Properties*
configuration section so the files are persisted in the `output` directory.

---

# License

This project is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).

LibreNMS has its own license, this license only covers the Docker part.
