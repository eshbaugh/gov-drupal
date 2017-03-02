#!/bin/bash

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
    ln -s $src $dst
    echo $src $dst
  done </var/application/.mounts
fi


exec /usr/sbin/apachectl -DFOREGROUND
