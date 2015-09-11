#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

# Setup SSH Server
apt-get install -qq openssh-server
cp $SCRIPT_PATH/templates/sshd_config /etc/ssh/sshd_config
mkdir -p /var/run/sshd
/regenerate_ssh_host_keys.sh

# Create needed directories / files if needed
mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys
chown -R root: /root/.ssh

cp $SCRIPT_PATH/templates/supervisor_sshd.conf /etc/supervisor/conf.d/
