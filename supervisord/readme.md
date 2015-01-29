# Supervisord

* Installs supervisord
* Copies default supervisord.conf to /etc/supervisord.conf
* Copies default start.sh script to /start.sh

The start script start supervisord in foreground.
It allows the override of docker CMD (docker run -t -i image /bin/bash will launch /bin/bash)