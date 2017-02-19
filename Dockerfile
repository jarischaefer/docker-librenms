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
		dnsutils \
		nginx \
		php7.0-cli \
		php7.0-fpm \
		php7.0-mysql \
		php7.0-gd \
		php7.0-curl \
		php7.0-opcache \
		php7.0-ldap \
		php7.0-memcached \
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
		nagios-plugins \
		nmap \
		python-mysqldb \
		rrdcached \
		rrdtool \
		sendmail \
		smbclient \
		git && \
	rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/* && \
	sed -i 's/pm.max_children = 5/pm.max_children = 24/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	sed -i 's/pm.start_servers = 2/pm.start_servers = 4/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 8/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	sed -i 's/;clear_env/clear_env/g' /etc/php/7.0/fpm/pool.d/www.conf && \
	useradd librenms -d /opt/librenms -M -r && \
	usermod -a -G librenms www-data && \
	curl -ssL "https://github.com/librenms/librenms/archive/1.24.tar.gz" | tar xz -C /opt && \
	mv /opt/librenms-1.24 /opt/librenms && \
	chown -R librenms:librenms /opt/librenms && \
	apt-get -yq autoremove --purge && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service && \
	chmod 644 /etc/cron.d/librenms

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl", "/var/log/nginx"]
