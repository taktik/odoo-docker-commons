#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

# scripts
cp $SCRIPT_PATH/scripts/start_etcd.sh /
chmod +x /*.sh
