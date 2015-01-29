#!/bin/bash

SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`

# etcd
curl -L  https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz -o /tmp/etcd.tar.gz
tar -xzvf /tmp/etcd.tar.gz -C /tmp/
mv /tmp/etcd-*/etcdctl /usr/local/bin/
mv /tmp/etcd-*/etcd /usr/local/bin/
chmod +x /usr/local/bin/etcd*
