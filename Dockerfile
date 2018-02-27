FROM jarischaefer/baseimage-librenms:1.1

ARG LIBRENMS_VERSION=ff02fced6e2bfa78776c5458d73079800916c58a
ENV TZ=UTC \
	RRDCACHED_LISTEN=unix:/var/run/rrdcached/rrdcached.sock \
	RRDCACHED_CONNECT=unix:/var/run/rrdcached/rrdcached.sock
EXPOSE 80 443

RUN cd /opt && \
	composer create-project --no-dev --keep-vcs librenms/librenms librenms dev-master#${LIBRENMS_VERSION} && \
	chown -R librenms:librenms /opt/librenms

ADD files /
RUN	chmod -R +x /etc/my_init.d /etc/service && \
	find /opt/librenms \( ! -user librenms -o ! -group librenms \) -exec chown librenms:librenms {} \; && \
	chmod 644 /etc/cron.d/librenms

VOLUME ["/opt/librenms/logs", "/opt/librenms/rrd", "/etc/nginx/ssl", "/var/log/nginx"]
