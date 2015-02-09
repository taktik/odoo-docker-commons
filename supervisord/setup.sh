#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

pip install supervisor
pip install supervisor-stdout

# Copy default conf and start script
cp $SCRIPT_PATH/templates/supervisord.conf /etc/supervisord.conf
cp $SCRIPT_PATH/scripts/start.sh /
chmod +x /*.sh
