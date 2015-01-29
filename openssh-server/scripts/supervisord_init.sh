#!/bin/bash

echo "Adding SSH to supervisord"
cat >> /etc/supervisord.conf <<EOF

[program:sshd]
command=/usr/sbin/sshd -D
stdout_events_enabled=true
stderr_events_enabled=true

EOF
echo "SSH added to supervisord"
