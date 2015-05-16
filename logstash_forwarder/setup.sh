#!/bin/bash

LOGSTASH_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get -qq update
apt-get -qq install logstash-forwarder
mkdir -p /etc/pki/tls/certs
