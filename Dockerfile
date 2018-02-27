FROM jarischaefer/baseimage-librenms:1.0

ARG LIBRENMS_VERSION=ff92960c64dccad16aee7dcd9af4a49362176dfa
ENV TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock
EXPOSE 80 443

RUN	git clone -b master -n https://github.com/librenms/librenms.git /opt/librenms && \
	cd /opt/librenms && \
	git checkout "$LIBRENMS_VERSION" && \
	chown -R librenms:librenms /opt/librenms

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/librenms

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl", "/var/log/nginx"]
