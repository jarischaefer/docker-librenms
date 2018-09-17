FROM jarischaefer/baseimage-librenms:2.0.2

ARG LIBRENMS_VERSION=1.43
ENV	TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock \
	SNMP_SCAN_CRON="0 0 * * *" \
	WEATHERMAP_CRON="*/5 * * * *"
EXPOSE 80 443

RUN	cd /opt && \
	composer global require hirak/prestissimo && \
	composer create-project --no-dev --keep-vcs librenms/librenms librenms ${LIBRENMS_VERSION} && \
	composer global remove hirak/prestissimo && \
	composer clear-cache && \
	cd /opt/librenms/html/plugins && \
	git clone --depth 1 https://github.com/librenms-plugins/Weathermap.git && \
	cp /opt/librenms/.env.example /opt/librenms/.env && \
	chown -R librenms:librenms /opt/librenms

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service /usr/local/bin && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/* /etc/librenms/cron/*

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl", "/var/log/nginx"]
