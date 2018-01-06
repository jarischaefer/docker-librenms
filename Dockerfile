FROM jarischaefer/baseimage-librenms

ARG LIBRENMS_VERSION=c6b9f04ae0c47b9ce0b9e07b51c0a5b5bfdc7267
ENV TZ=UTC
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
