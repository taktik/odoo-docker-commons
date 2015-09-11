#!/bin/bash

MYSQL_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

apt-get update
apt-get -qq install mysql-server mysql-client

sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

mkdir -p /var/log/mysql

cp $MYSQL_SCRIPT_PATH/scripts/mysql_backup.sh /usr/local/bin/
cp $MYSQL_SCRIPT_PATH/scripts/mysql_restore.sh /usr/local/bin/
cp $MYSQL_SCRIPT_PATH/templates/supervisor_mysql.conf /etc/supervisor/conf.d/
chmod +x /usr/local/bin/mysql_*.sh
