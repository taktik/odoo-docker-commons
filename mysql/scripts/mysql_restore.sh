#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "$0 database dump_file";
    exit 1;
fi

mysql -u root -p $1 < $2
echo "Database $1 was restored"
