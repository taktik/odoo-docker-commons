# Logstash forwarder

## Instructions
To be able to use logstash forwarder, a configuration file must be present in the container:

- /etc/logstash-forwarder.conf

Without this file, logstash-forwarder will be disabled.

You can use the example file in the examples directory.  
This file can be shared directly from the host, for instance by adding the following volume when running the container:

- /media/DATA/odoo/containers/name/logstash-forwarder.conf/:/etc/logstash-forwarder.conf
