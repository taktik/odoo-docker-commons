#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

apt-get update
apt-get install -qq openswan xl2tpd ppp
apt-get install -qq lsof iptables ufw vim netcat nmap net-tools cifs-utils smbclient

# Copy the configuration files to a template directory.
# Each time we run, we then copy the files from the template directory to /etc.
# This allows us to always substitute variables from the templates (when the container restarts and the IP changes for instance).
mkdir -p /vpn/templates/
cp $SCRIPT_PATH/templates/ipsec.conf /vpn/templates/
cp $SCRIPT_PATH/templates/ipsec.secrets /vpn/templates/

cp $SCRIPT_PATH/xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
cp $SCRIPT_PATH/options.xl2tpd /etc/ppp/options.xl2tpd
cp $SCRIPT_PATH/chap-secrets /etc/ppp/chap-secrets

cp $SCRIPT_PATH/bin/* /usr/local/sbin/

cat >> /etc/supervisord.conf <<EOF

[program:vpn]
command=/usr/local/sbin/run
process_name=%(program_name)s
stopsignal=INT
autostart=true
autorestart=true
redirect_stderr=true
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/var/log/vpn.log

EOF
