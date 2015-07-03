#!/bin/bash

# Slightly modified script from
# https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux
# This script is the pg_backup_rotated.sh.
# Modified to not create a directory per day, and keep specified number of monthly/weekly backups.

###########################
####### LOAD CONFIG #######
###########################

while [ $# -gt 0 ]; do
        case $1 in
                -c)
                        CONFIG_FILE_PATH="$2"
                        shift 2
                        ;;
                *)
                        ${ECHO} "Unknown Option \"$1\"" 1>&2
                        exit 2
                        ;;
        esac
done

if [ -z $CONFIG_FILE_PATH ] ; then
        SCRIPTPATH=$(cd ${0%/*} && pwd -P)
        CONFIG_FILE_PATH="${SCRIPTPATH}/pg_backup.config"
fi

if [ ! -r ${CONFIG_FILE_PATH} ] ; then
        echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][error] \"Could not load config file from ${CONFIG_FILE_PATH}\"" 1>&2
        exit 1
fi

source "${CONFIG_FILE_PATH}"
source /root/.profile

###########################
#### PRE-BACKUP CHECKS ####
###########################

# Make sure we're running as the required backup user
if [ "$BACKUP_USER" != "" -a "$(id -un)" != "$BACKUP_USER" ]; then
	echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][error] This script must be run as $BACKUP_USER. Exiting." 1>&2
	exit 1
fi


###########################
#### START THE BACKUPS ####
###########################

function perform_backups()
{
	SUFFIX=$1
	FINAL_BACKUP_DIR=$BACKUP_DIR
	SUFFIX="`date +\%Y\%m\%d_\%H%M`$SUFFIX"

	echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][debug] \"Making backup in directory $FINAL_BACKUP_DIR\""

	if ! mkdir -p $FINAL_BACKUP_DIR; then
		echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][error] \"Cannot create backup directory in $FINAL_BACKUP_DIR. Go and fix it!\"" 1>&2
		exit 1;
	fi;


	###########################
	###### FULL BACKUPS #######
	###########################

    BACKUP_FILTER_CLAUSE=""
    if [ -n "$BACKUP_ONLY_FILTER" ] && [ "$BACKUP_ONLY_FILTER" != "false" ]; then
        BACKUP_FILTER_CLAUSE=" and datname ~ '$BACKUP_ONLY_FILTER'"
    fi

	FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn $BACKUP_FILTER_CLAUSE order by datname;"

	echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][debug] \"Performing full backups\""

	for DATABASE in `psql -At -c "$FULL_BACKUP_QUERY" postgres`
	do
		if [ $ENABLE_PLAIN_BACKUPS = "yes" ]
		then
			echo "`date -u +'%Y-%m-%dT%H:%M:%SZ'` \"Plain backup of $DATABASE\""

			if ! pg_dump -Fp -h "$DATABASE" | gzip > $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".sql.gz.in_progress; then
				echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][error] \"$DATABASE\" 0 \"Failed to produce plain backup\"" 1>&2
			else
				mv $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".sql.gz.in_progress $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".sql.gz
				echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][info] \"$DATABASE\" `du $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".sql.gz  | cut -f -1` \"$FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".sql.gz\"" # Use cut to only show bytes (no filename)
			fi
		fi

		if [ $ENABLE_CUSTOM_BACKUPS = "yes" ]
		then
			echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][debug] \"Custom backup of $DATABASE\""

			if ! pg_dump -Fc "$DATABASE" -f $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".dump.in_progress; then
				echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][error] \"$DATABASE\" 0 \"Failed to produce custom backup\""
			else
				mv $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".dump.in_progress $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".dump
				echo "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][info] \"$DATABASE\" `du $FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".dump  | cut -f -1` \"$FINAL_BACKUP_DIR"$DATABASE"_"$SUFFIX".dump\"" # Use cut to only show bytes (no filename)
			fi
		fi

	done

	echo -e "[`date -u +'%Y-%m-%dT%H:%M:%SZ'`][debug] \"All database backups complete!\""
}

# MONTHLY BACKUPS
# Only if first day of month and hour is 23 (this script can be executed
# several times a day)

DAY_OF_MONTH=`date +%d`
HOUR=`date +%H`
EXPIRED_DAYS=`expr $((($MONTHS_TO_KEEP * 30) + 1))`

if [ "$DAY_OF_MONTH" -eq 1 ] && [ "$HOUR" -eq 23 ];
then
	# Delete all expired monthly directories
	find $BACKUP_DIR -maxdepth 1 -type f -mtime +$EXPIRED_DAYS -name "*-monthly.*" -exec rm -rf '{}' ';'

	perform_backups "-monthly"

	exit 0;
fi

# WEEKLY BACKUPS
# Only if day of week is the day specified in the config
# and hour is 23

DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
EXPIRED_DAYS=`expr $((($WEEKS_TO_KEEP * 7) + 1))`

if [ "$DAY_OF_WEEK" = $DAY_OF_WEEK_TO_KEEP ]  && [ "$HOUR" -eq 23 ];
then
	# Delete all expired weekly directories
	find $BACKUP_DIR -maxdepth 1 -type f -mtime +$EXPIRED_DAYS -name "*-weekly.*" -exec rm -rf '{}' ';'

	perform_backups "-weekly"

	exit 0;
fi

# Delete daily backups 7 days old or more
find $BACKUP_DIR -maxdepth 1 -type f -mtime +$DAYS_TO_KEEP ! -name "*-monthly.*" ! -name "*-weekly.*" ! -name "pg_backup.config" -exec rm -rf '{}' ';'

perform_backups
