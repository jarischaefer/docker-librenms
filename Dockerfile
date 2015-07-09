################
#
# Mounts:
#	- /opt/librenms/logs
#	- /opt/librenms/rrd
#   - /opt/librenms/config.custom.php
#	- /etc/nginx/ssl
#
################

FROM phusion/baseimage:0.9.16
MAINTAINER Jari Schäfer <jari.schaefer@gmail.com>

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
	echo 'deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main' > /etc/apt/sources.list.d/ondrej-php56.list && \
	apt-get update && \
	apt-get -yq dist-upgrade && \
	apt-get -yq install --no-install-recommends \
		nginx \
		php5 \
		php5-cli \
		php5-fpm \
		php5-mysqlnd \
		php5-gd \
		php5-curl \
		php-pear \
		snmp \
		graphviz \
		fping \
		imagemagick \
		whois \
		mtr-tiny \
		nmap \
		python-mysqldb \
		php-net-ipv4 \
		php-net-ipv6 \
		rrdtool \
		sendmail \
		git && \
	rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/* && \
	useradd librenms -d /opt/librenms -M -r -g www-data && \
	cd /opt && \
	git clone --depth 1 https://github.com/librenms/librenms.git librenms && \
	cp /opt/librenms/config.php.default /opt/librenms/config.php && \
	apt-get -yq autoremove --purge && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD files/etc /etc/
RUN chmod -R +x /etc/service && chmod 644 /etc/cron.d/librenms

EXPOSE 80
EXPOSE 443
