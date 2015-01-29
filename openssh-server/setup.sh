#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

# Setup SSH Server
apt-get install -qq openssh-server
cp $SCRIPT_PATH/templates/sshd_config /etc/ssh/sshd_config
mkdir /var/run/sshd
/regenerate_ssh_host_keys.sh

# Create needed directories / files if needed
mkdir -p /root/.ssh
touch /root/.ssh/authorized_keys

mkdir -p /home/openerp/.ssh
touch /home/openerp/.ssh/authorized_keys

# Copy default key in authorized_keys to be able to login
if [ -f $SCRIPT_PATH/templates/id_rsa_docker.pub ]; then
    cat $SCRIPT_PATH/templates/id_rsa_docker.pub >> /root/.ssh/authorized_keys
    cat $SCRIPT_PATH/templates/id_rsa_docker.pub >> /home/openerp/.ssh/authorized_keys
fi

chown -R root: /root/.ssh
