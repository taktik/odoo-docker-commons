# PostgreSQL

Installs PostgreSQL 9.3 and some binaries.

## Available binaries

- backupDatabase.sh, to dump a database in /usr/local/openerp/backups
- dropAndImportDB.sh, to drop a database and replace it by the specified dump
- pgBackup.sh, to handle backups
- pgClientReplicationStatus.sh, to check the replication status of the clients (slaves)
- pgCreateRole.sh, create the specified role and add it to the openerp role
- pgKillSessions.sh, kill the sessions of the specified database
- pgReplicationStatus, check the replication status (slave)

## Dependencies

Depends on [supervisor](../supervisord/readme.md).  
