# Logstash forwarder

## Instructions
To be able to use logstash forwarder, a configuration file must be present:

- /etc/logstash_conf/logstash-forwarder.conf

You can use the example file in the examples directory.
This file can be shared directly from the host, for instance by adding the following volume when running the container:

- /media/DATA/odoo/containers/name/logstash_conf/:/etc/logstash_conf/
