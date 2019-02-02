FROM jarischaefer/baseimage-librenms:2.3

ARG LIBRENMS_VERSION=1.48.1
ENV	TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock \
	SNMP_SCAN_CRON="0 0 * * *" \
	WEATHERMAP_CRON="*/5 * * * *"
EXPOSE 80 443

RUN	cd /opt && \
	composer global require hirak/prestissimo && \
	composer create-project --no-dev --keep-vcs librenms/librenms librenms ${LIBRENMS_VERSION} && \
	/opt/librenms/scripts/composer_wrapper.php install --no-dev && \
	composer global remove hirak/prestissimo && \
	composer clear-cache && \
	cd /opt/librenms/html/plugins && \
	git clone --depth 1 https://github.com/librenms-plugins/Weathermap.git && \
	cp /opt/librenms/.env.example /opt/librenms/.env && \
	chown -R librenms:librenms /opt/librenms && \
	find /opt/librenms -name '.gitignore' -type f -exec chmod -x "{}" + && \
	mkdir -p /opt/helpers/default_files/logs /opt/helpers/default_files/rrd && \
	cp /opt/librenms/logs/.gitignore /opt/helpers/default_files/logs && \
	cp /opt/librenms/rrd/.gitignore /opt/helpers/default_files/rrd

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service /usr/local/bin && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/* /etc/librenms/cron/*

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/opt/librenms/storage"]
VOLUME ["/opt/librenms/html/plugins/Weathermap/configs", "/opt/librenms/html/plugins/Weathermap/output"]
VOLUME ["/etc/nginx/ssl", "/var/log/nginx"]
