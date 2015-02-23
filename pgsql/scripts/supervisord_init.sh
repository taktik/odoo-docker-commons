#!/bin/bash

# Add to supervisord.conf
cat >> /etc/supervisord.conf <<EOF

[program:postgresql]
user=postgres
command=/usr/lib/postgresql/9.3/bin/postgres -c config-file=/etc/postgresql/9.3/main/postgresql.conf -D /var/lib/pgsql/9.2/data/ -c listen-addresses=*
process_name=%(program_name)s
stopsignal=INT
autostart=true
autorestart=true
redirect_stderr=true
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/var/log/postgresql.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10

EOF
