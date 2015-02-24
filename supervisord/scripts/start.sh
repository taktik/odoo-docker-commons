#!/bin/bash

# Create log subdirectories if needed (if folder shared between host and container)
mkdir -p /var/log/mysql
mkdir -p /var/log/nginx

# start all the services
exec /usr/local/bin/supervisord -n
