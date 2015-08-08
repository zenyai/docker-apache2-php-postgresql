FROM ubuntu:trusty
MAINTAINER zenyai <narongdej@sarnsuwan.com>

ENV POSTGRES_VERSION 9.3

# Installing packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common supervisor apache2 php5 php5-mcrypt
RUN php5enmod mcrypt
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main $POSTGRES_VERSION" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql-$POSTGRES_VERSION postgresql-client-$POSTGRES_VERSION postgresql-contrib-$POSTGRES_VERSION php5-pgsql
RUN apt-get clean
RUN echo "host    all    all    0.0.0.0/0    md5" >> /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf

# Scripts
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-apache2.sh /supervisord-apache2.sh
ADD supervisord-postgresql.conf /etc/supervisor/conf.d/supervisord-postgresql.conf
ADD supervisord-postgresql.sh /supervisord-postgresql.sh
ADD start.sh /start.sh
RUN chmod 755 /*.sh

# PHP application folder
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

# Run Compose
# RUN cd /app && php -r "readfile('https://getcomposer.org/installer');" | php && php composer.phar install

# PostgreSQL data folders
RUN mkdir -p /var/run/postgresql/9.3-main.pg_stat_tmp
RUN chown postgres /var/run/postgresql/9.3-main.pg_stat_tmp
RUN chgrp postgres /var/run/postgresql/9.3-main.pg_stat_tmp
RUN mkdir -p /var/lib/postgresql && mkdir -p /var/log/postgresql
VOLUME ["/var/log/postgresql", "/var/lib/postgresql"]

# Copy APACHE settings
ADD apache2.conf /etc/apache2/apache2.conf

EXPOSE 80 5432
CMD ["/start.sh"]
