#!/bin/bash
SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

apt-get update
apt-get install -qq build-essential

curl -L https://collectd.org/files/collectd-5.5.0.tar.gz -o /tmp/collectd.tar.gz
tar -xzvf /tmp/collectd.tar.gz -C /tmp/
cd /tmp/collectd-5.5.0/
./configure
make all install
