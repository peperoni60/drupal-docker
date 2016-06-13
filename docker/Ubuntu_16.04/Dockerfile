# Php 7.0
FROM ubuntu:16.04

# install reqired software: apache2 and php
RUN apt-get update \
    && apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
       apache2 \
       mysql-client \
       libapache2-mod-php \
       php-mysql \
       php-gd \
       php-apcu \
       php-curl \
       php-xdebug \
       php-sqlite3 \
       wget \
       curl \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod php7.0 \
    && a2enmod rewrite

# Set up debugger
# Please provide your host (local machine IP):
RUN echo "xdebug.remote_host=172.17.0.1" >> /etc/php/7.0/mods-available/xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /etc/php/7.0/mods-available/xdebug.ini \
    && phpenmod xdebug

ENV APACHE_RUN_USER www-data \
    APACHE_RUN_GROUP www-data \
    APACHE_LOG_DIR /var/log/apache2 \
    APACHE_LOCK_DIR /var/lock/apache2 \
    APACHE_PID_FILE /var/run/apache2.pid \

EXPOSE 80 443

# Publish volumes
VOLUME /var/www /etc/php /var/log/apache2 /sendmail

ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
ADD sendmail.sh /usr/sbin/sendmail

CMD /usr/sbin/apache2ctl -D FOREGROUND

WORKDIR /var/www/docroot