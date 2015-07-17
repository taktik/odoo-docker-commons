#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

# PostgreSQL
echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update
LC_ALL=en_US.UTF-8 apt-get -qq install postgresql-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

mkdir -p /config/pg_backup/

# Scripts
cp $SCRIPT_PATH/scripts/backupDatabase.sh /usr/local/bin/
cp $SCRIPT_PATH/scripts/dropAndImportDB.sh /usr/local/bin/
cp $SCRIPT_PATH/scripts/pg_backup.sh /usr/local/bin/
cp $SCRIPT_PATH/scripts/pgClientReplicationStatus.sh /usr/local/bin/
cp $SCRIPT_PATH/scripts/pgCreateRole.sh /usr/local/bin/
cp $SCRIPT_PATH/scripts/pgKillSessions.sh /usr/local/bin/
cp $SCRIPT_PATH/scripts/pgReplicationStatus.sh /usr/local/bin/
cp $SCRIPT_PATH/templates/pg_backup.config /config/pg_backup/
cp $SCRIPT_PATH/templates/supervisor_pgsql.conf /etc/supervisor/conf.d/
