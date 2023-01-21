#!/bin/bash

msg -org "Setting SSLH"
msg -org "Membuat konfigurasi /etc/default/sslh"
rm -f /etc/default/sslh &>/dev/null
cat >/etc/default/sslh <<-END
	# Default options for sslh initscript
	# sourced by /etc/init.d/sslh

	# Disabled by default, to force yourself
	# to read the configuration:
	# - /usr/share/doc/sslh/README.Debian (quick start)
	# - /usr/share/doc/sslh/README, at "Configuration" section
	# - sslh(8) via "man sslh" for more configuration details.
	# Once configuration ready, you *must* set RUN to yes here
	# and try to start sslh (standalone mode only)

	RUN=yes

	# binary to use: forked (sslh) or single-thread (sslh-select) version
	# systemd users: don't forget to modify /lib/systemd/system/sslh.service
	DAEMON=/usr/sbin/sslh

	DAEMON_OPTS="--user sslh --listen 0.0.0.0:$openssh --ssl 127.0.0.1:$ssl1 --ssh 127.0.0.1:$dropbear2 --openvpn 127.0.0.1:$openvpn_tcp --http 127.0.0.1:$http1 --pidfile /var/run/sslh/sslh.pid -n"
END

# Restart Service SSLH
msg -org "Restart Service SSLH"
cmd "systemctl restart sslh"
cmd "/etc/init.d/sslh status"

c_port $file_port ssl1 $ssl1
c_port $file_port http1 $http1

ufw allow $ssl1 &>/dev/null
ufw allow $http1 &>/dev/null