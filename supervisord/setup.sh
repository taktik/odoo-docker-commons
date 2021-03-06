#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

pip install supervisor
pip install supervisor-stdout

mkdir -p /etc/supervisor/conf.d/
mkdir -p /var/log/supervisor/

# Copy default conf and start script
cp $SCRIPT_PATH/templates/supervisord.conf /etc/supervisord.conf
cp $SCRIPT_PATH/scripts/start.sh /
chmod +x /*.sh
