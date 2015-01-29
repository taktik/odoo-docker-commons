#!/bin/bash
##Version##1.0##
if [[ ! ($1 && $2) ]]
then 
echo "Usage : dropdbAndImportPostgresDB <db-name> <dump file>" && exit
fi
echo "Drop db ..." ;\
sudo -u postgres dropdb $1 ;\
echo "...........dropped" &&\
echo "Create db ..." &&\
sudo -u postgres createdb -U openerp -E UTF-8 $1 --template=template0 &&\
echo ".............created" &&\
echo "Restore db ..." &&\
sudo -u postgres pg_restore -d $1 -U openerp $2 &&\
echo "...............restored"
