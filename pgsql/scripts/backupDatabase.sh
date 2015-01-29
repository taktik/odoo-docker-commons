#!/bin/bash
##Version##1.0##
outputdir="/usr/local/openerp/backups"

if [ "$1" == "" ]
then
	echo "$0 CLIENTNAME"
	exit 1;
fi
date=`/bin/date +%Y%m%d-%Hh%M`

sudo -u postgres /usr/bin/pg_dump -F c -U postgres -f "$outputdir/$1_${date}.dump" $1
echo "$outputdir/$1_${date}.dump"
