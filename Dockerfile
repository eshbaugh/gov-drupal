FROM centos/httpd
MAINTAINER Ron Williams <hello@ronwilliams.io>
ENV PATH /usr/local/src/vendor/bin/:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm

# Fix command line compile issue with bundler.
ENV LC_ALL en_US.utf8

# Disable services management by systemd.
RUN systemctl disable httpd.service && \
    systemctl disable rsyslog.service

# Install and enable repositories
Run yum -y install \
    epel-release


RUN yum -y groupinstall "Development Tools" && \
    yum -y install \
    curl \
    git \
    mariadb \
    msmtp \
    net-tools \
    python34 \
    rsync \
    tmux \
    vim \
    wget

# Install PHP and PHP modules
RUN yum -y install \
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

# Install misc tools
RUN yum -y install \
    python-setuptools \
    rsyslog

# Perform yum cleanup
RUN yum clean all

# Apply My_Init Workarounds
RUN mkdir /etc/container_environment
RUN mkdir /etc/workaround-docker-2267

# Install supervisor. Requires python-setuptools.
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

# Apache config, and PHP config, test apache config
# See https://github.com/docker/docker/issues/7511 /tmp usage
COPY public/index.php /var/www/public/index.php
COPY centos-7 /tmp/centos-7/
RUN rsync -a /tmp/centos-7/etc/httpd /etc/ && \
    apachectl configtest
RUN rsync -a /tmp/centos-7/etc/php* /etc/

COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/lamp.sh /etc/lamp.sh
COPY conf/my_init /
RUN chmod +x /my_*

EXPOSE 80 443

RUN chmod +x /etc/lamp.sh
CMD ["/my_init"]
