#!/bin/bash
#
# This script gets the VHOST configuration from the environment variables
# and register to etcd (if the container was linked to the etcd container).
# It stores the configuration in /hosts/ip_of_the_container.
# Then it starts ping_etcd.sh to update the TTL of the directory of the configuration.
# Every environment variables starting by VHOST will treated by the script.
# The configuration can be defined with a compact (shortcut) form:
# VHOST=external_port:internal_port:hostname1,hostname2
# Or you can use full parameters (or a combination of the two, compact + some parameters):
# VHOST_EXTERNAL_PORT=80
# VHOST_INTERNAL_PORT=8069
# VHOST_HOSTNAMES=hostname1,hostname2
# VHOST_SSL_ENFORCE=1
# VHOST_SSL_CERTIFICATE=/path/to/certificate
# VHOST_SSL_CERTIFICATE_KEY=/path/to/certificate_key
#

if [ "$ETCD_PORT_4001_TCP_ADDR" != "false" ]; then
    IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
    IP_clean="${IP//\./_}"
    echo "[etcd_host] `date +\%Y/\%m/\%d\ \%H:%M:%S` container IP: $IP"
    echo "[etcd_host] `date +\%Y/\%m/\%d\ \%H:%M:%S` registering to etcd"
    VHOSTS=$(printenv | grep "VHOST");
    if [ -n "$VHOSTS" ]; then
        pkill -9 "ping_etcd" # Kill ping_etcd.sh if already launched
        etcdctl -C "$ETCD" mkdir "/hosts/$IP_clean" --ttl 30
        etcdctl -C "$ETCD" set "/hosts/$IP_clean/ip" "$IP"
        while read -r line; do
            vhost_number=$(echo $line | sed -r 's!(VHOST)([0-9]*)(.*)=(.*)!\2!')
            if [ -z "$vhost_number" ]; then
                vhost_number=0;
            fi
            if [[ "$line" == *":"* ]]; then
                # Compact declaration (e.g. external_port:internal_port:hostnames)
                line=$(echo "$line" | sed -e 's/VHOST.*=//'); # Keep only values
                IFS=':' read -a vhost <<< "$line"
                if [ "${#vhost[@]}" -ne 3 ]; then
                    echo "Vhost line incorrect. Should be external_port:internal_port:hostname1,hostname2";
                else
                    external_port=${vhost[0]};
                    internal_port=${vhost[1]};
                    hostnames=${vhost[2]};
                    etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/external_port" "$external_port"
                    etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/internal_port" "$internal_port"
                    etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/hostnames" "$hostnames"
                    i=$((i+1))
                fi
            else
                # VHOST parameter (e.g. VHOST_EXTERNAL_PORT=80)
                IFS='=' read -a vhost <<< "$line" # Split line on =
                option=$(echo "${vhost[0]}" | sed -r 's/VHOST([0-9]*)_//' | tr '[:upper:]' '[:lower:]') # Remove VHOST_ and keep only the option name (VHOST_ENFORCE_SSL => ENFORCE_SSL)
                value="${vhost[1]}"

                etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/$option" "$value"
            fi
        done <<< "$VHOSTS"
        /ping_etcd.sh & # Update TTL
    else
        echo "[etcd_host] `date +\%Y/\%m/\%d\ \%H:%M:%S` no vhost environment variable defined."
    fi
fi
