################
#
# Mounts:
#	- /opt/librenms/logs
#	- /opt/librenms/rrd
#	- /opt/librenms/config.custom.php
#	- /etc/nginx/ssl
#
################

FROM phusion/baseimage:0.9.19
MAINTAINER Jari Schäfer <jari.schaefer@gmail.com>

EXPOSE 80 443

RUN	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C C300EE8C && \
	echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/ondrej-php7.list && \
	echo 'deb http://ppa.launchpad.net/nginx/development/ubuntu xenial main' > /etc/apt/sources.list.d/nginx.list && \
	apt-get update && \
	apt-get -yq purge openssh-.* && \
	apt-get -yq autoremove --purge && \
	apt-get -yq dist-upgrade && \
	apt-get -yq install --no-install-recommends \
		nginx \
		php7.0-cli \
		php7.0-fpm \
		php7.0-mysql \
		php7.0-gd \
		php7.0-curl \
		php7.0-opcache \
		php-imagick \
		php-pear \
		php-net-ipv4 \
		php-net-ipv6 \
		snmp \
		graphviz \
		fping \
		imagemagick \
		whois \
		mtr-tiny \
		nmap \
		python-mysqldb \
		rrdtool \
		sendmail \
		git && \
	rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/* && \
	sed -i 's/;opcache.enable=0/opcache.enable=1/g' /etc/php/7.0/fpm/php.ini && \
	sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=1/g' /etc/php/7.0/fpm/php.ini && \
	sed -i 's/;opcache.enable_file_override=0/opcache.enable_file_override=1/g' /etc/php/7.0/fpm/php.ini && \
	sed -i 's/;opcache.revalidate_path=0/opcache.revalidate_path=1/g' /etc/php/7.0/fpm/php.ini && \
	sed -i 's/;opcache.load_comments=0/opcache.load_comments=0/g' /etc/php/7.0/fpm/php.ini && \
	sed -i 's/;opcache.save_comments=0/opcache.save_comments=0/g' /etc/php/7.0/fpm/php.ini && \
	sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/g' /etc/php/7.0/fpm/php.ini && \
	sed -i 's/pm.max_children = 5/pm.max_children = 24/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	sed -i 's/pm.start_servers = 2/pm.start_servers = 4/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 8/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	echo 'include_path = ".:/usr/share/php:/usr/lib/php/pear"' >> /etc/php/7.0/fpm/php.ini && \
	echo 'include_path = ".:/usr/share/php:/usr/lib/php/pear"' >> /etc/php/7.0/cli/php.ini && \
	useradd librenms -d /opt/librenms -M -r -g www-data && \
	cd /opt && \
	curl -ssL "https://github.com/librenms/librenms/archive/201607.tar.gz" | tar xzf - && \
	mv librenms-201607 librenms && \
	cp /opt/librenms/config.php.default /opt/librenms/config.php && \
	sed -i 's/#$config\['"'"'update'"'"'\]/$config['"'"'update'"'"']/g' /opt/librenms/config.php && \
	apt-get -yq autoremove --purge && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD files/etc /etc/
RUN	chmod -R +x /etc/my_init.d /etc/service && \
	chmod 644 /etc/cron.d/librenms

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl"]
