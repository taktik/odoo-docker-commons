#!/bin/bash

LOGSTASH_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get -qq update
apt-get -qq install logstash-forwarder
mkdir -p /etc/pki/tls/certs

# Remove default logstash-forwarder.conf
rm /etc/logstash-forwarder.conf > /dev/null 2>&1 || true

# Copy supervisor conf file but disable it by default
cp $LOGSTASH_SCRIPT_PATH/scripts/start_logstash_forwarder.sh /
cp $LOGSTASH_SCRIPT_PATH/templates/supervisor_logstash_forwarder.conf /etc/supervisor/conf.d/supervisor_logstash_forwarder.conf.disabled

chmod +x /*.sh
