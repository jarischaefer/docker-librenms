FROM jarischaefer/baseimage-librenms:3.2

ENV	TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock \
	SNMP_SCAN_CRON="0 0 * * *" \
	WEATHERMAP_CRON="*/5 * * * *" \
	POLLERS=8 \
	POLLERS_CRON="*/5 * * * *" \
	INSTALL=false
EXPOSE 80 443

ADD pre_install /

RUN	chmod +x /build/install && /build/install && rm -r /build

ADD post_install /

RUN	chmod -R +x /etc/my_init.d /etc/service /usr/local/bin && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/* /etc/librenms/cron/*

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/opt/librenms/storage"]
VOLUME ["/opt/librenms/html/plugins/Weathermap/configs", "/opt/librenms/html/plugins/Weathermap/output"]
VOLUME ["/etc/nginx/ssl", "/var/log/nginx"]
