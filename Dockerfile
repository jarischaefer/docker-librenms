FROM jarischaefer/baseimage-librenms:1.3

ARG LIBRENMS_VERSION=1.37
ENV TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock
EXPOSE 80 443

RUN cd /opt && \
	composer create-project --no-dev --keep-vcs librenms/librenms librenms ${LIBRENMS_VERSION} && \
	composer clear-cache && \
	chown -R librenms:librenms /opt/librenms

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/* /etc/librenms/cron/snmp-scan

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl", "/var/log/nginx"]
