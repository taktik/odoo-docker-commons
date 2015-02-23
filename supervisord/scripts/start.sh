#!/bin/bash

# If CMD was overriden, execute directly the command (e.g. /bin/bash)
if [ "$#" -gt 0 ]; then
    "$@"
else
    # Create log subdirectories if needed (if folder shared between host and container)
    mkdir -p /var/log/mysql
    mkdir -p /var/log/nginx

    # start all the services
    exec /usr/local/bin/supervisord -n
fi
