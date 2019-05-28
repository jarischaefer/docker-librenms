FROM jarischaefer/baseimage-librenms:2.6

ENV	LIBRENMS_VERSION=1.52 \
	LIBRENMS_WEATHERMAP_VERSION=5bb4fcccbaa9f5801325b9d79e811575c37fd84e \
	TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock \
	SNMP_SCAN_CRON="0 0 * * *" \
	WEATHERMAP_CRON="*/5 * * * *" \
	POLLERS=8 \
	POLLERS_CRON="*/5 * * * *"
EXPOSE 80 443

RUN	git clone --branch ${LIBRENMS_VERSION} https://github.com/librenms/librenms.git /opt/librenms && \
	composer global require hirak/prestissimo && \
	composer --no-interaction install --working-dir=/opt/librenms --no-dev --prefer-dist && \
	composer global remove hirak/prestissimo && \
	composer clear-cache && \
	curl -qsSL https://github.com/librenms-plugins/Weathermap/archive/${LIBRENMS_WEATHERMAP_VERSION}.tar.gz | tar -xz -C /opt/librenms/html/plugins && \
	mv /opt/librenms/html/plugins/Weathermap-${LIBRENMS_WEATHERMAP_VERSION} /opt/librenms/html/plugins/Weathermap && \
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
