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
# VHOST=external_port:internal_port:hostname1,hostname2[:prefix]
# If a prefix is defined, the configuration will be stored under the prefix in etcd (instead of hosts).
# Or you can use full parameters (or a combination of the two, compact + some parameters):
# VHOST_EXTERNAL_PORT=80
# VHOST_INTERNAL_PORT=8069
# VHOST_HOSTNAMES=hostname1,hostname2
# VHOST_SSL_ENFORCE=1
# VHOST_SSL_CERTIFICATE=/path/to/certificate
# VHOST_SSL_CERTIFICATE_KEY=/path/to/certificate_key
#
import os
import datetime
import time
import re
import sh

etcd_ip = os.getenv("ETCD", False)
vhosts = {}


def process_output(line):
    print(datetime.datetime.now().isoformat() + " " + line.rstrip('\r\n'))


if not etcd_ip:
    process_output("No etcd ip found")
    exit(1)


def get_ip(interface=None):
    """
    Get the IP of the specified interface
    :param interface: interface
    :return: ip address or False
    """
    eth0 = sh.ifconfig('eth0')
    ip = re.search(r'inet addr:(\S+)', str(eth0))
    if not ip:
        return False

    return ip.group(1)


def init():
    """
    Get the VHOST parameters from the environment variables, put them in the vhosts dictionary
    and persist them in etcd.
    :return: True
    """
    # verbose
    # process_output(
    #     "Get the VHOST parameters from the environment variables, "
    #     "put them in the vhosts dictionary and persist them in etcd."
    # )
    ip = get_ip("eth0")
    if not ip:
        process_output("No IP address found")
        exit(1)

    process_output("Registering to etcd. Container IP: %s" % ip)
    sanitized_ip = ip.replace(".", "_")
    # verbose
    # process_output("Sanitized ip : %s" % sanitized_ip)

    # verbose
    # process_output("Iteration : sh.grep(sh.printenv(), '^VHOST', _iter=True)")
    for vhost in sh.grep(sh.printenv(), "^VHOST", _iter=True):
        # The environment variable will be of the form
        # VHOST=80:8080:domain.com (compact form) or VHOST_EXTERNAL_PORT=80 (full mode)
        # We can also specify multiple vhosts, i.e.
        # VHOST2=88:8080:domain2.com or VHOST2_EXTERNAL_PORT=88
        vhost = vhost.rstrip('\r\n')  # Remove carriage return
        vhost_number = 0  # VHOST will be 0, VHOST2 will be 2, etc.
        vhost_parameter = False  # i.e. get external_port from VHOST_EXTERNAL_PORT
        # verbose
        # process_output("VHOST before split : %s" % str(vhost))
        vhost, value = vhost.split("=")
        # verbose
        # process_output("VHOST after split : %s" % str(vhost))
        if len(vhost) > 5:
            # process_output("vhost > 5")
            # i.e. VHOST_SOMETHING
            config = re.search(r'VHOST(\d+)*(?:_)*(.*)', vhost)
            if config:
                vhost_number = config.group(1) or 0
                # verbose
                # process_output("vhost_number : %s" % str(vhost_number))
                vhost_parameter = config.group(2) or False
                # verbose
                # process_output("vhost_parameter : %s" % str(vhost_parameter))

        if not vhost_parameter:
            # Compact form, i.e. VHOST=8080:80:domain.com
            # verbose
            # process_output("IF NOT vhost parameter")
            short_parameters = value.split(":")
            if len(short_parameters) < 3:
                process_output("Vhost line incorrect: %s. Should be external_port:internal_port:hostname1,hostname2[:etcd_prefix]" % vhost)
                continue

            vhosts.setdefault(vhost_number, {}).update({
                "external_port": short_parameters[0].lower()
            })
            # verbose
            # process_output("external_port : %s" % str(short_parameters[0].lower()))
            vhosts.setdefault(vhost_number, {}).update({
                "internal_port": short_parameters[1].lower()
            })
            # verbose
            # process_output("internal_port : %s" % str(short_parameters[1].lower()))
            vhosts.setdefault(vhost_number, {}).update({
                "hostnames": short_parameters[2].lower()
            })
            # verbose
            # process_output("hostnames : %s" % str(short_parameters[2].lower()))

            if len(short_parameters) >= 4:
                # verbose
                # process_output("IF short_parameters >= 4")
                vhosts.setdefault(vhost_number, {}).update({
                    "prefix": short_parameters[3].lower()
                })
                # process_output("prefix : %s" % str(short_parameters[3].lower()))

        else:
            # verbose
            # process_output("IF vhost parameter exist")
            vhosts.setdefault(vhost_number, {}).update({vhost_parameter.lower(): value})
            # verbose
            # process_output("key : %s" % str(vhost_parameter.lower()))
            # process_output("value : %s" % str(value))

    # verbose
    # process_output("Iteration : vhosts.iteritems()")
    for vhost_number, values in vhosts.iteritems():
        prefix = values.get('prefix', 'hosts')
        # verbose
        # process_output("values : %s" % str(values))
        # process_output("prefix : %s" % str(prefix))
        try:
            # TTL of 300 because sh commands are sometimes slow, and we have to let some time for all the VHOST configuration
            # to be set.
            # verbose
            # process_output("TRY EXCEPT 1 : sh.etcdctl")
            # process_output("sh.etcdctl : mkdir  %s/%s % (prefix, sanitized_ip), --ttl, 300")
            # process_output("ETCD ENV VAR - etcd_ip : %s" % str(etcd_ip))
            # process_output("prefix : %s" % str(prefix))
            # process_output("sanitized_ip : %s" % str(sanitized_ip))
            sh.etcdctl("-C", etcd_ip, "mkdir", "%s/%s" % (prefix, sanitized_ip), "--ttl", "300", _err=process_output)
        except Exception, e:
            # verbose
            # process_output("EXCEPTION : TRY EXCEPT 1 : sh.etcdctl")
            # process_output("Probably key already exists")
            # process_output("Will pass : %s" % str(e))
            pass  # Probably key already exists

        try:
            # verbose
            # process_output("sh.etcdctl : set  %s/%s/ip % (prefix, sanitized_ip), %s % ip")
            # process_output("ETCD ENV VAR - etcd_ip : %s" % str(etcd_ip))
            # process_output("prefix : %s" % str(prefix))
            # process_output("sanitized_ip : %s" % str(sanitized_ip))
            sh.etcdctl("-C", etcd_ip, "set", "%s/%s/ip" % (prefix, sanitized_ip), "%s" % ip, _err=process_output)
            for key, value in values.iteritems():
                # verbose
                # process_output("sh.etcdctl : set %s/%s/config/%s/%s % (prefix, sanitized_ip, vhost_number, key), %s % value")
                # process_output("ETCD ENV VAR - etcd_ip : %s" % str(etcd_ip))
                # process_output("prefix : %s" % str(prefix))
                # process_output("sanitized_ip : %s" % str(sanitized_ip))
                # process_output("vhost_number : %s" % str(vhost_number))
                # process_output("key : %s" % str(key))
                sh.etcdctl("-C", etcd_ip, "set", "%s/%s/config/%s/%s" % (prefix, sanitized_ip, vhost_number, key), "%s" % value, _err=process_output)

        except Exception, e:
            # verbose
            # process_output("EXCEPTION : TRY EXCEPT 2 : sh.etcdctl")
            # process_output("Will pass : %s" % str(e))
            pass

    return True


init()

while True:
    try:
        # Update TTL on every VHOST (they can have different prefixes)
        ip = get_ip("eth0")
        if not ip:
            process_output("No IP address found")
            exit(1)

        sanitized_ip = ip.replace(".", "_")

        for vhost_number, values in vhosts.iteritems():
            prefix = values.get('prefix', 'hosts')
            try:
                sh.etcdctl("-C", etcd_ip, "updatedir", "%s/%s" % (prefix, sanitized_ip), "--ttl", "30", _err=process_output)
            except Exception, e:
                # process_output("EXCEPTION : TRY EXCEPT sh.etcdctl(-C, etcd_ip, updatedir, %s/%s % (prefix, sanitized_ip), --ttl, 30, _err=process_output)")
                # process_output("time.sleep(15)")
                pass
                exit(1)
        # process_output("time.sleep(15)")
        time.sleep(15)
    except KeyboardInterrupt:
        process_output("Stopping start_etcd")
