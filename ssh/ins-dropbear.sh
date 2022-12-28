#!/bin/bash

### Setup dropbear
msg -line " Setting DropBear "
msg -org "sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear"
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear &>/dev/null

msg -org "sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=$dropbear3/g' /etc/default/dropbear"
sed -i "s/DROPBEAR_PORT=22/DROPBEAR_PORT=$dropbear3/g" /etc/default/dropbear &>/dev/null

msg -org "sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS=\"-p $dropbear2 -p 1153\"/g' /etc/default/dropbear"
sed -i "s/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS=\"-p $dropbear2 -p 1153\"/g" /etc/default/dropbear &>/dev/null
msg -org "echo \"/bin/false\" >>/etc/shells"
echo "/bin/false" >>/etc/ &>/dev/null
msg -org "echo \"/usr/sbin/nologin\" >>/etc/shells"
echo "/usr/sbin/nologin" >>/etc/shells &>/dev/null
msg -org "Restart DropBear"
cmd "/etc/init.d/dropbear restart" &>/dev/null

c_port $file_port dropbear1 $dropbear1
c_port $file_port dropbear2 $dropbear2
c_port $file_port dropbear3 $dropbear3

# install squid (proxy nya aku matikan)
cd $home
#apt -y install squid3
#wget -O /etc/squid/squid.conf "${pssh}/squid3.conf"
#sed -i $IP2 /etc/squid/squid.conf
