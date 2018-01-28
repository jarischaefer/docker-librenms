FROM jarischaefer/baseimage-librenms:1.0

ARG LIBRENMS_VERSION=92e1048940638a738c8c12aa27337871bfc3a06f
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
