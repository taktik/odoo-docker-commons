#!/bin/bash

echo "Adding vsFTPd to supervisord"
cat >> /etc/supervisord.conf <<EOF

[program:vsftpd]
command=/usr/sbin/vsftpd
process_name=%(program_name)s
stopsignal=INT
autostart=true
autorestart=unexpected
redirect_stderr=true
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/var/log/vsftpd.log
stdout_logfile_maxbytes=20MB
stdout_logfile_backups=5
stderr_logfile_maxbytes=20MB
stderr_logfile_backups=5

EOF
echo "vsFTPd added to supervisord"
