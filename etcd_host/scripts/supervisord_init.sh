#!/bin/bash

echo "Adding etcd to supervisord"
cat >> /etc/supervisord.conf <<EOF

[program:etcd]
command=/start_etcd.sh
process_name=%(program_name)s
stopsignal=INT
autostart=true
autorestart=true
redirect_stderr=true
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/var/log/etcd_start.log
stdout_logfile_maxbytes=20MB
stdout_logfile_backups=5
stderr_logfile_maxbytes=20MB
stderr_logfile_backups=5

EOF
echo "etcd added to supervisord"
