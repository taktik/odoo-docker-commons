#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

pip install sh

# scripts
cp $SCRIPT_PATH/scripts/start_etcd.py /
cp $SCRIPT_PATH/templates/supervisor_etcd.conf /etc/supervisor/conf.d/
chmod +x /*.sh
