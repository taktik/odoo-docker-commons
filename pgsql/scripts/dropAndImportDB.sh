#!/bin/bash
##Version##1.0##
if [[ ! ($1 && $2) ]]
then 
echo "Usage : dropdbAndImportPostgresDB <db-name> <dump file>" && exit
fi
echo "Drop db ..." ;\
dropdb $1 ;\
echo "...........dropped" &&\
echo "Create db ..." &&\
createdb -E UTF-8 $1 --template=template0 &&\
echo ".............created" &&\
echo "Restore db ..." &&\
pg_restore -d $1 $2 &&\
echo "...............restored"
