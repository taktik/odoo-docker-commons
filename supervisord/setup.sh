#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

# Python Setuptools, pip
easy_install pip

# Supervisord to handle our processes
easy_install supervisor
easy_install supervisor-stdout

# Upgrade setuptools
pip install setuptools --no-use-wheel --upgrade

# Copy default conf and start script
cp $SCRIPT_PATH/templates/supervisord.conf /etc/supervisord.conf
cp $SCRIPT_PATH/scripts/start.sh /
chmod +x /*.sh
