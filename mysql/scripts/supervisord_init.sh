#!/bin/bash

echo "Adding MySQL to supervisord"
cat >> /etc/supervisord.conf <<EOF

[program:mysqld]
command=/usr/bin/mysqld_safe
stdout_events_enabled=true
stderr_events_enabled=true
redirect_stderr=true
stdout_logfile=/var/log/mysql.log
stdout_logfile_maxbytes=20MB
stdout_logfile_backups=5
stderr_logfile_maxbytes=20MB
stderr_logfile_backups=5

EOF
echo "MySQL added to supervisord"