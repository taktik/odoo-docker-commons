#!/bin/bash
SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
CURRENT_DIR=`pwd`

apt-get update
apt-get install -qq build-essential

curl -L https://collectd.org/files/collectd-5.5.0.tar.gz -o /tmp/collectd.tar.gz
tar -xzvf /tmp/collectd.tar.gz -C /tmp/
cd /tmp/collectd-5.5.0/
./configure
make all install

# By default, disable collectd
mv /etc/collectd/collectd.conf /etc/collectd/collectd.conf.example 2>&1 || true

# Scripts and templates
cd "$CURRENT_DIR"
cp $SCRIPT_PATH/scripts/start_collectd.sh /
cp $SCRIPT_PATH/templates/supervisor_collectd.conf /etc/supervisor/conf.d/
chmod +x /*.sh
