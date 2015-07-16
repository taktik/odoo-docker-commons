#!/bin/bash
# Create the specified role and add it to the openerp role

if [[ ! ($1 && $2) ]]
then
    echo "Usage : pgCreateRole <role-name> <password>" && exit
fi

psql -U postgres -c "CREATE USER \"$1\" WITH CREATEDB PASSWORD '$2';"
psql -U postgres -c "GRANT openerp TO \"$1\";"
echo "User $1 created"
