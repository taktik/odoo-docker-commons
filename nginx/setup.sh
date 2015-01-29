#!/bin/bash

NGINX_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
CURRENT_DIR=`pwd`

apt-get update
apt-get -qq install libpcre3 libpcre3-dev zlib1g-dev # Useful for rewrite module

mkdir -p /var/log/nginx

mkdir /nginx
cd /nginx
wget http://nginx.org/download/nginx-1.6.0.tar.gz
tar xzvf nginx-1.6.0.tar.gz
cd nginx-1.6.0
./configure \
    --sbin-path=/usr/local/sbin \
    --conf-path=/etc/nginx/nginx.conf \
    --user=www-data \
    --group=www-data \
    --pid-path=/var/run/nginx.pid \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_ssl_module \
    --with-http_mp4_module \
    --with-http_realip_module
make
make install

mkdir -p /etc/nginx/sites-enabled/
mkdir -p /etc/nginx/sites-available/

cd "$CURRENT_DIR"
cp $NGINX_SCRIPT_PATH/templates/nginx.conf /etc/nginx/nginx.conf
cp $NGINX_SCRIPT_PATH/templates/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
