# Logstash forwarder

Installs [logstash-forwarder](https://github.com/elastic/logstash-forwarder).

## Usage

Logstash-forwarder will start only if the configuration file /etc/logstash-forwarder.conf is present.  
An exemple is available [here](examples/logstash-forwarder.conf) or in the container at /etc/logstash-forwarder.conf.example.

## Dependencies

Depends on [supervisor](../supervisord/readme.md).  
If the /etc/collectd/collectd.conf file is not present, the program will exit immediately with a status code 3, allowed in the
supervisord configuration and thus not automatically restarted.
