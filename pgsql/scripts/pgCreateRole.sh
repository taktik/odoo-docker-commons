#!/bin/bash

if [[ ! ($1 && $2) ]]
then
    echo "Usage : pgCreateRole <role-name> <password>" && exit
fi

psql -U postgres -c "CREATE USER \"$1\" WITH CREATEDB PASSWORD '$2';"
echo "User $1 created"
