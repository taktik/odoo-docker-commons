#!/bin/bash

echo "Adding Apache to supervisord"
cat >> /etc/supervisord.conf <<EOF

[program:apache]
command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
process_name=%(program_name)s
stopsignal=INT
autostart=true
autorestart=true
redirect_stderr=true
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/var/log/httpd.log

EOF
echo "Apache added to supervisord"
