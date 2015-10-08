#!/bin/bash

# Start supervisord in foreground with given configuration
/bin/supervisord \
  --nodaemon \
  --configuration=/etc/supervisord.conf
