#!/bin/bash

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

file_env 'DOCROOT'
if [ ! -z "$DOCROOT" ] && ! grep -q "^DocumentRoot \"$DOCROOT\"" /etc/httpd/conf/httpd.conf ; then
	sed -i "s#/var/www/public#$DOCROOT#g" /etc/httpd/conf/httpd.conf
fi
echo "export DOCROOT='$DOCROOT'" > /etc/profile.d/docroot.sh

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

# Perform git pull
if [ -d "/var/application/.git" ]; then
  if [ -v GIT_BRANCH ]; then
    git --git-dir=/var/application git checkout $GIT_BRANCH
    git --git-dir=/var/application git pull origin $GIT_BRANCH
  else
    git --git-dir=/var/application git checkout master
    git --git-dir=/var/application git pull origin master
  fi
else
  if [ -v GIT_URL ]; then
    git clone $GIT_URL /var/application
    if [ -d "/var/application/.git" ]; then
      if [ -v GIT_BRANCH ]; then
        git --git-dir=/var/application git checkout $GIT_BRANCH
        git --git-dir=/var/application git pull origin $GIT_BRANCH
      fi
    fi
  fi
fi

# Symlink appropriate directories into the drupal document root
# It would be good to have a more dynamic way to do this
# to support other use cases
if [ -f "/var/application/.mounts" ]; then
  while read p; do
    src=$(echo $p | cut -f1 -d:)
    dst=$(echo $p | cut -f2 -d:)
    # Removes existing files to allow symlink to apply in all cases.
    rm -fR $dst
    ln -s $src $dst
    echo $src $dst
  done </var/application/.mounts
fi

exec /usr/sbin/apachectl -DFOREGROUND
