#!/bin/bash

echo "Adding logstash-forwarder to supervisord"
cat >> /etc/supervisord.conf <<EOF

[program:logstash]
command=/opt/logstash-forwarder/bin/logstash-forwarder -config /etc/logstash-forwarder.conf
process_name=%(program_name)s
directory=/var/run
autostart = true
autorestart = true
priority = 10
stdout_logfile=/var/log/logstash-forwarder.log
redirect_stderr=true
stdout_logfile_maxbytes=20MB
stdout_logfile_backups=5
stderr_logfile_maxbytes=20MB
stderr_logfile_backups=5
stopsignal=INT

EOF
echo "logstash-forwarder added to supervisord"
