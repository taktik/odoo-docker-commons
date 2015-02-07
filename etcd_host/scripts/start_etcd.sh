#!/bin/bash
#
# This script gets the VHOST configuration from the environment variables
# and register to etcd (if the container was linked to the etcd container).
# It stores the configuration in /hosts/ip_of_the_container.
# Then it loops indefinitely to update the TTL of the directory of the configuration (every 15 seconds).
#
# This script should be launched with supervisord or equivalent process control system in order
# to be relaunched if an error occurred.
#
# Every environment variables starting by VHOST will be treated by the script.
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
        etcdctl -C "$ETCD" mkdir "/hosts/$IP_clean" --ttl 30 2>&1 1> /dev/null # Redirect stderr to stdout then stdout to null
        etcdctl -C "$ETCD" set "/hosts/$IP_clean/ip" "$IP" 2>&1 1> /dev/null   # so only stderr will be printed in the log
        while read -r line; do
            vhost_number=$(echo $line | sed -r 's!(VHOST)([0-9]*)(.*)=(.*)!\2!') # VHOST will be 0, VHOST1 1, VHOST2 2, etc.
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
                    etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/external_port" "$external_port" 2>&1 1> /dev/null
                    etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/internal_port" "$internal_port" 2>&1 1> /dev/null
                    etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/hostnames" "$hostnames" 2>&1 1> /dev/null
                    i=$((i+1))
                fi
            else
                # VHOST parameter (e.g. VHOST_EXTERNAL_PORT=80)
                IFS='=' read -a vhost <<< "$line" # Split line on =
                option=$(echo "${vhost[0]}" | sed -r 's/VHOST([0-9]*)_//' | tr '[:upper:]' '[:lower:]') # Remove VHOST_ and keep only the option name (VHOST_ENFORCE_SSL => ENFORCE_SSL)
                value="${vhost[1]}"

                etcdctl -C "$ETCD" set "/hosts/$IP_clean/config/$vhost_number/$option" "$value" 2>&1 1> /dev/null
            fi
        done <<< "$VHOSTS"
        echo "[etcd_host] `date +\%Y/\%m/\%d\ \%H:%M:%S` starting to ping etcd every 15 secs."
        while true; do

            IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
            IP_clean="${IP//\./_}"

            # Update TTL on directory
            if ! etcdctl -C "$ETCD" updatedir "/hosts/$IP_clean" --ttl 30; then
                echo "[etcd_host] `date +\%Y/\%m/\%d\ \%H:%M:%S` etcdctl returned $?. The key $IP_clean was probably not found."
                exit 1;
            fi

            sleep 15;

        done
    else
        echo "[etcd_host] `date +\%Y/\%m/\%d\ \%H:%M:%S` no vhost environment variable defined."
    fi
fi
