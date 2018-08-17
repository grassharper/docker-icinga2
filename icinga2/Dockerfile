# Docker container with Icinga2
FROM alpine:latest

MAINTAINER Andrei Buzoianu <andrei.buzoianu@gmail.com>

LABEL version="1.0" description="Icinga2 container"

ENV ICINGA2_FEATURE_PGSQL false
ENV ICINGA2_PGSQL_DB icinga2
ENV ICINGA2_PGSQL_USER icinga2
ENV ICINGA2_PGSQL_PASSWORD icinga2
ENV ICINGA2_PGSQL_HOST postgres

ENV ICINGA2_FEATURE_MYSQL true
ENV ICINGA2_MYSQL_DB icinga2
ENV ICINGA2_MYSQL_USER icinga2
ENV ICINGA2_MYSQL_PASSWORD icinga2
ENV ICINGA2_MYSQL_HOST mariadb

ENV ICINGA2_FEATURE_API true
ENV ICINGA2_API_USER root
ENV ICINGA2_API_PASSWORD api

ENV ICINGA2_FEATURE_ELASTICSEARCH false
ENV ICINGA2_ELASTICSEARCH_HOST elasticsearch
ENV ICINGA2_ELASTICSEARCH_PORT 9200
ENV ICINGA2_ELASTICSEARCH_INDEX icinga2
ENV ICINGA2_ELASTICSEARCH_SEND_PERFDATA true
ENV ICINGA2_ELASTICSEARCH_FLUSH_THRESHOLD 1024
ENV ICINGA2_ELASTICSEARCH_FLUSH_INTERVAL 10s

ENV ICINGA2_FEATURE_COMMAND true
ENV ICINGA2_FEATURE_CHECKER true
ENV ICINGA2_FEATURE_LIVESTATUS true
ENV ICINGA2_FEATURE_STATUSDATA true

RUN apk --update add --no-cache icinga2 postgresql-client mariadb-client fping mailx

VOLUME ["/etc/icinga2", "/var/lib/icinga2"]

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 750 /usr/local/bin/docker-entrypoint.sh; \
 ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 5665
CMD ["/usr/sbin/icinga2", "daemon", "-c", "/etc/icinga2/icinga2.conf"]
