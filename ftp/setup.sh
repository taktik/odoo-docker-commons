#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

apt-get update
apt-get install -qq vsftpd

# See vsftpd.conf.
mkdir -p /var/run/vsftpd/empty

cp $SCRIPT_PATH/templates/vsftpd.conf /etc/
cp $SCRIPT_PATH/templates/vsftpd.allowed_users /etc/
