#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

# Setup APT sources
echo "deb http://ubuntu.mirrors.skynet.be/ubuntu trusty main restricted universe multiverse" | tee /etc/apt/sources.list
echo "deb http://ubuntu.mirrors.skynet.be/ubuntu trusty-updates main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "deb http://ubuntu.mirrors.skynet.be/ubuntu trusty-security main restricted universe multiverse" | tee -a /etc/apt/sources.list
echo "deb http://ubuntu.mirrors.skynet.be/ubuntu trusty-backports main restricted universe multiverse" | tee -a /etc/apt/sources.list

# Base dependencies
apt-get update
apt-get install -qq apache2 apache2-mpm-event
apt-get -qq upgrade

# Needed directories
mkdir -p /var/run/apache2/ && chown -R www-data: /var/run/apache2/
mkdir -p /var/lock/apache2 && chown -R www-data: /var/lock/apache2
mkdir -p /var/log/apache2 && chown -R www-data: /var/log/apache2
rm /etc/apache2/sites-enabled/000-default.conf

# Apache config
a2enmod rewrite
a2enmod ssl
a2enmod proxy
a2enmod proxy_http
a2enmod headers

# Scripts
chmod +x /*.sh
