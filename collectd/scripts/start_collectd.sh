#!/bin/bash
#
# Start collectd only if configuration file /etc/collectd/collectd.conf was found.
#

if [ ! -f "/etc/collectd/collectd.conf" ]; then
        echo "Configuration file /etc/collectd/collectd.conf not found, exiting"
        exit 3; # Special exit code (in allowed exitcodes of supervisod configuration file).
else
        exec /opt/collectd/sbin/collectd -f -C /etc/collectd/collectd.conf
fi
