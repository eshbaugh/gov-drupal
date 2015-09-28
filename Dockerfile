FROM centos:7
MAINTAINER Ron Williams <hello@ronwilliams.io>
ENV PATH /usr/local/src/vendor/bin/:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install and enable repositories
Run yum -y update && \
    yum -y install \
    epel-release

# Install base
RUN yum -y update && \
    yum -y groupinstall "Development Tools" && \
    yum -y install \
    curl \
    git \
    httpd \
    mariadb \
    net-tools \
    rsync \
    tmux \
    vim \
    wget

# Install PHP and PHP modules
RUN yum -y update && \
    yum -y install \
    php \
    php-curl \
    php-gd \
    php-imap \
    php-mbstring \
    php-mcrypt \
    php-mysql \
    php-odbc \
    php-pear \
    php-pecl-imagick \
    php-pecl-zendopcache

# No package mysql-client available. Fixed with mariadb.
# No package php-pecl-imagick available.
# No package php-mcrypt available.
# No package php-imap available.

# Install misc tools
RUN yum -y update && yum -y install \
    python-setuptools \
    rsyslog

# Install supervisor. Requires python-setuptools
RUN easy_install \
    supervisor

# Install Composer and Drush
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --version=1.0.0-alpha10 && \
    composer \
    --working-dir=/usr/local/src/ \
    global \
    require \
    drush/drush:7.* && \
    ln -s /usr/local/src/vendor/bin/drush /usr/bin/drush

# Run yum -y update && yum -y install \
#    php-fpm

# RUN yum -y update && yum -y install \
#     ImageMagick \
#     php-magickwand \

# # Cryus SASL library
# RUN yum -y update && yum -y install \
#     cyrus-sasl \
#     php-pear-Auth-SASL \  

# RUN pear install \
#     Mail \
#     Mail_Mime \
#     Net_SMTP \
#     Net_Socket \
#     XML_RPC

RUN systemctl disable httpd.service && \
    systemctl disable rsyslog.service

# Apache config
# See https://github.com/docker/docker/issues/7511 /tmp usage
COPY public/index.php /var/www/public/index.php
COPY centos-7 /tmp/centos-7/
RUN rsync -a /tmp/centos-7/etc/httpd /etc/ && \
    apachectl configtest

COPY conf/supervisord.conf /etc/supervisord.conf
# ADD conf/website.conf /etc/apache2/sites-available/000-default.conf
# ADD conf/httpd.conf /etc/apache2/apache2.conf
# ADD conf/php.ini /etc/php5/apache2/php.ini
# ADD conf/rsyslog.conf /etc/rsyslog.conf
COPY conf/lamp.sh /etc/lamp.sh

EXPOSE 80 443

RUN chmod +x /etc/lamp.sh
CMD ["/etc/lamp.sh"]
# CMD ["/usr/bin/bash","/etc/lamp.sh"]

# RUN php5enmod mcrypt

# RUN apt-get install -y supervisor
# RUN mkdir -p /var/log/supervisor

# RUN a2enmod rewrite
# RUN a2enmod php5

# RUN rm -f /etc/apache2/sites-available/000-default.conf

# ADD conf/supervisord.conf /etc/supervisord.conf
# ADD conf/website.conf /etc/apache2/sites-available/000-default.conf
# ADD conf/httpd.conf /etc/apache2/apache2.conf
# ADD conf/php.ini /etc/php5/apache2/php.ini
# ADD conf/rsyslog.conf /etc/rsyslog.conf
# ADD conf/lamp.sh /etc/lamp.sh

# RUN chmod +x /etc/lamp.sh

# # Add admin scripts to directory
# COPY conf/tools/ /usr/local/share/lap-docker/

# # Install Pimp My Logs
# RUN git clone https://github.com/potsky/PimpMyLog.git /usr/local/share/lap-docker/logs/
# ADD conf/pimpmylog/pimpmylog.ini /etc/php5/conf.d/pimpmylog.ini
# RUN cd /etc/php5/cli/conf.d && ln -s ../../conf.d/pimpmylog.ini pimpmylog.ini &&\
# cd /etc/php5/apache2/conf.d && ln -s ../../conf.d/pimpmylog.ini pimpmylog.ini

# # Allows apache to read log files directly
# RUN usermod -G adm www-data
# # Creates initial php error log
# RUN touch /var/log/apache2/php.err
# # Creates default configuration file
# ADD conf/pimpmylog/config.user.php /usr/local/share/lap-docker/logs/config.user.php


# # Fix session write warnings
# RUN chown www-data:www-data /var/lib/php5
# RUN chmod g+rwx /var/lib/php5

# RUN apachectl configtest
# RUN rm -rf /var/www

# # Install Mailcatcher Dependencies (sqlite, ruby)
# RUN apt-get install -y libsqlite3-dev ruby1.9.1-dev

# # Install Mailcatcher as a Ruby gem
# RUN gem install mailcatcher --no-rdoc --no-ri
# ADD conf/mailcatcher.upstart /etc/init.d/mailcatcher

# # Install drush for Drupal Development
# RUN apt-get install -y drush

# # Install Bundler and Theme related tweaks
# RUN gem install bundler
# RUN export LC_ALL="C.UTF-8"

# # Install Mailcatcher php configuration
# ADD conf/mailcatcher.ini /etc/php5/conf.d/mailcatcher.ini
# RUN cd /etc/php5/cli/conf.d && ln -s ../../conf.d/mailcatcher.ini mailcatcher.ini &&\
# cd /etc/php5/apache2/conf.d && ln -s ../../conf.d/mailcatcher.ini mailcatcher.ini


# RUN service apache2 stop
# RUN service rsyslog stop

# EXPOSE 80
# EXPOSE 443

# CMD ["/etc/lamp.sh"]
