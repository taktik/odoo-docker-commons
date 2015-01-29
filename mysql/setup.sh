#!/bin/bash

apt-get update
apt-get -qq install mysql-server mysql-client

sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

mkdir -p /var/log/mysql