#!/bin/bash
#
# This script pings etcd to update the TTL of the directory in which its
# configuration is stored (/hosts/ip_of_the_container).
# If the key is not found, it calls start_etcd.sh.
#

while true; do

    IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
    IP_clean="${IP//\./_}"

    # Update TTL on directory
    if ! etcdctl -C "$ETCD" updatedir "/hosts/$IP_clean" --ttl 30; then
        echo "[etcd_host] `date +\%Y/\%m/\%d\ \%H:%M:%S` etcdctl returned $?. The key $IP_clean was probably not found. Launching start_etcd.sh." >> /var/log/ping-etcd.log
        /start_etcd.sh
    fi

    sleep 15;

done
