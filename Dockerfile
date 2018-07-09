FROM jarischaefer/baseimage-librenms:1.7

ARG LIBRENMS_VERSION=1.41
ENV	TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock \
	SNMP_SCAN_CRON="0 0 * * *"
EXPOSE 80 443

RUN	cd /opt && \
	composer global require hirak/prestissimo && \
	composer create-project --no-dev --keep-vcs librenms/librenms librenms ${LIBRENMS_VERSION} && \
	composer global remove hirak/prestissimo && \
	composer clear-cache && \
	chown -R librenms:librenms /opt/librenms

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/* /etc/librenms/cron/snmp-scan

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl", "/var/log/nginx"]
