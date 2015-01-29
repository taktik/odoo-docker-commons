#!/bin/bash

echo "Adding Nginx to supervisord"
cat >> /etc/supervisord.conf <<EOF

[program:nginx]
command=/usr/local/sbin/nginx
autorestart=true
stdout_events_enabled=true
stderr_events_enabled=true
redirect_stderr=true
stdout_logfile=/var/log/nginx.log
stdout_logfile_maxbytes=20MB
stdout_logfile_backups=5
stderr_logfile_maxbytes=20MB
stderr_logfile_backups=5

EOF
echo "Nginx added to supervisord"