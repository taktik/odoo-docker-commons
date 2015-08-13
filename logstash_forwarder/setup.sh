#!/bin/bash

LOGSTASH_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get -qq update
apt-get -qq install logstash-forwarder
mkdir -p /etc/pki/tls/certs

# By default disable logstash-forwarder
mv /etc/logstash-forwarder.conf /etc/logstash-forwarder.conf.example > /dev/null 2>&1 || true

# Create logstash-forwarder working directory
mkdir -p /home/logstash

# Scripts and templates
cp $LOGSTASH_SCRIPT_PATH/scripts/start_logstash_forwarder.sh /
cp $LOGSTASH_SCRIPT_PATH/templates/supervisor_logstash_forwarder.conf /etc/supervisor/conf.d/
chmod +x /*.sh
