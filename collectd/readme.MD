# Collectd

Installs collectd 5.5.0.  

## Usage

Collectd will start only if the configuration file /etc/collectd/collectd.conf is present.  
An example is availble [here](examples/collectd.conf) or in the container at /etc/collectd/collectd.conf.example.

## Dependencies

Depends on [supervisor](../supervisord/readme.md).  
If the /etc/collectd/collectd.conf file is not present, the program will exit immediately with a status code 3, allowed in the
supervisord configuration and thus not automatically restarted.