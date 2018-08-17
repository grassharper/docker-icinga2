#!/usr/bin/env sh
set -euf -o pipefail

if [ "$1" = '/usr/sbin/icinga2' ] && [ "$(id -u)" = '0' ]; then
	mkdir -p /run/icinga2/cmd
	chown -R icinga:icinga /run/icinga2
	chown icinga:icinga /etc/icinga2
fi

if [ "$1" = '/usr/sbin/icinga2' ]; then
	if ${ICINGA2_FEATURE_COMMAND}; then 
		if [ ! -f /etc/icinga2/features-enabled/command.conf ]; then
			icinga2 feature enable command
		fi
	fi

	if ${ICINGA2_FEATURE_CHECKER}; then 
		if [ ! -f /etc/icinga2/features-enabled/checker.conf ]; then
			# The checker component takes care of executing service checks.
			icinga2 feature enable checker
		fi
	fi

	if ${ICINGA2_FEATURE_LIVESTATUS}; then 
		if [ ! -f /etc/icinga2/features-enabled/livestatus.conf ]; then
			# The livestatus library implements the livestatus query protocol
			icinga2 feature enable livestatus
		fi
	fi

	if ${ICINGA2_FEATURE_STATUSDATA}; then 
		if [ ! -f /etc/icinga2/features-enabled/statusdata.conf ]; then
			# The StatusDataWriter type periodically updates the status.dat and objects.cache
			# files. These are used by the Icinga 1.x CGIs to display the state of
			# hosts and services.
			icinga2 feature enable statusdata
		fi
	fi

	if ${ICINGA2_FEATURE_MYSQL} && [ ! -f /etc/icinga2/features-enabled/ido-mysql.conf ]; then
		# Enable IDO for MySQL. This is needed by icinga-web.
		icinga2 feature enable ido-mysql

		if [ ! -z ${ICINGA2_MYSQL_USER} ]; then 
 			sed -i "s/\/\/user.*/user = \"${ICINGA2_MYSQL_USER}\"/g" /etc/icinga2/features-available/ido-mysql.conf
		fi

		if [ ! -z ${ICINGA2_MYSQL_PASSWORD} ]; then 
 			sed -i "s/\/\/password.*/password = \"${ICINGA2_MYSQL_PASSWORD}\"/g" /etc/icinga2/features-available/ido-mysql.conf
		fi

		if [ ! -z ${ICINGA2_MYSQL_HOST} ]; then 
			echo $ICINGA2_MYSQL_HOST
 			sed -i "s/\/\/host.*/host = \"${ICINGA2_MYSQL_HOST}\"/g" /etc/icinga2/features-available/ido-mysql.conf
		fi

		if [ ! -z ${ICINGA2_MYSQL_DB} ]; then 
 			sed -i "s/\/\/database.*/database = \"${ICINGA2_MYSQL_DB}\"/g" /etc/icinga2/features-available/ido-mysql.conf
		fi

		while ! /usr/bin/mysqladmin -h ${ICINGA2_MYSQL_HOST} -u${ICINGA2_MYSQL_USER} -p${ICINGA2_MYSQL_PASSWORD} --silent ping; do
			sleep 1
		done

		/usr/bin/mysql -h ${ICINGA2_MYSQL_HOST} -u${ICINGA2_MYSQL_USER} -p${ICINGA2_MYSQL_PASSWORD} ${ICINGA2_MYSQL_DB} < /usr/share/icinga2-ido-mysql/schema/mysql.sql
	fi

	if ${ICINGA2_FEATURE_PGSQL} && [ ! -f /etc/icinga2/features-enabled/ido-pgsql.conf ]; then
		# Enable IDO for PgSQL. This is needed by icinga-web.
		icinga2 feature enable ido-pgsql

		if [ ! -z ${ICINGA2_PGSQL_USER} ]; then 
 			sed -i "s/\/\/user.*/user = \"${ICINGA2_PGSQL_USER}\"/g" /etc/icinga2/features-available/ido-pgsql.conf
		fi

		if [ ! -z ${ICINGA2_PGSQL_PASSWORD} ]; then 
 			sed -i "s/\/\/password.*/password = \"${ICINGA2_PGSQL_PASSWORD}\"/g" /etc/icinga2/features-available/ido-pgsql.conf
		fi

		if [ ! -z ${ICINGA2_PGSQL_HOST} ]; then 
			echo $ICINGA2_PGSQL_HOST
 			sed -i "s/\/\/host.*/host = \"${ICINGA2_PGSQL_HOST}\"/g" /etc/icinga2/features-available/ido-pgsql.conf
		fi

		if [ ! -z ${ICINGA2_PGSQL_DB} ]; then 
 			sed -i "s/\/\/database.*/database = \"${ICINGA2_PGSQL_DB}\"/g" /etc/icinga2/features-available/ido-pgsql.conf
		fi

		while ! /usr/bin/pg_isready -h ${ICINGA2_PGSQL_HOST} -U ${ICINGA2_PGSQL_USER}; do
			sleep 1
		done

		PGPASSWORD=${ICINGA2_PGSQL_PASSWORD} /usr/bin/psql -h ${ICINGA2_PGSQL_HOST} -U ${ICINGA2_PGSQL_USER} -d ${ICINGA2_PGSQL_DB} -f /usr/share/icinga2-ido-pgsql/schema/pgsql.sql
	fi

	if ${ICINGA2_FEATURE_ELASTICSEARCH} && [ ! -f /etc/icinga2/features-enabled/elasticsearch.conf ]; then
		icinga2 feature enable elasticsearch

		if [ ! -z ${ICINGA2_ELASTICSEARCH_HOST} ]; then 
 			sed -i "s/\/\/host.*/host = \"${ICINGA2_ELASTICSEARCH_HOST}\"/g" /etc/icinga2/features-available/elasticsearch.conf
		fi
		if [ ! -z ${ICINGA2_ELASTICSEARCH_PORT} ]; then 
 			sed -i "s/\/\/port.*/port = \"${ICINGA2_ELASTICSEARCH_PORT}\"/g" /etc/icinga2/features-available/elasticsearch.conf
		fi
		if [ ! -z ${ICINGA2_ELASTICSEARCH_INDEX} ]; then 
 			sed -i "s/\/\/port.*/port = \"${ICINGA2_ELASTICSEARCH_INDEX}\"/g" /etc/icinga2/features-available/elasticsearch.conf
		fi
		if [ ! -z ${ICINGA2_ELASTICSEARCH_SEND_PERFDATA} ]; then 
 			sed -i "s/\/\/enable_send_perfdata.*/enable_send_perfdata = \"${ICINGA2_ELASTICSEARCH_SEND_PERFDATA}\"/g" /etc/icinga2/features-available/elasticsearch.conf
		fi
		if [ ! -z ${ICINGA2_ELASTICSEARCH_FLUSH_THRESHOLD} ]; then 
 			sed -i "s/\/\/flush_threshold.*/flush_threshold = \"${ICINGA2_ELASTICSEARCH_FLUSH_THRESHOLD}\"/g" /etc/icinga2/features-available/elasticsearch.conf
		fi
		if [ ! -z ${ICINGA2_ELASTICSEARCH_FLUSH_INTERVAL} ]; then 
 			sed -i "s/\/\/flush_interval.*/flush_interval = \"${ICINGA2_ELASTICSEARCH_FLUSH_INTERVAL}\"/g" /etc/icinga2/features-available/elasticsearch.conf
		fi
	fi

	if ${ICINGA2_FEATURE_API}; then 
		icinga2 api setup
		sed -i "s/password =.*/password = \"${ICINGA2_API_PASSWORD}\"/g" /etc/icinga2/conf.d/api-users.conf
	fi

fi

exec "$@"
