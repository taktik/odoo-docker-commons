#!/bin/bash
outputdir="/usr/local/backups"

mkdir -p "$outputdir"

if [ "$1" == "" ]
then
	echo "$0 databasename"
	exit 1;
fi

date=`/bin/date +%Y%m%d-%Hh%M`

/usr/bin/mysqldump -u root $1 > "$outputdir/$1_${date}.sql"
echo "$outputdir/$1_${date}.sql"
