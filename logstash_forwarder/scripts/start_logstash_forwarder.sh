#!/bin/bash
#
# If /etc/logstash-forwarder.conf file is present, activate the logstash-forwarder.conf supervisor configuration.
#

if [ -f "/etc/logstash-forwarder.conf" ]; then
    echo "Activating logstash-forwarder supervisor script"
    mv /etc/supervisor/conf.d/supervisor_logstash_forwarder.conf.disabled /etc/supervisor/conf.d/supervisor_logstash_forwarder.conf > /dev/null 2>&1 || true
else
    echo "De-activating logstash-forwarder supervisor script"
    mv /etc/supervisor/conf.d/supervisor_logstash_forwarder.conf /etc/supervisor/conf.d/supervisor_logstash_forwarder.conf.disabled > /dev/null 2>&1 || true
fi
