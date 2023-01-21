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
cmd "/etc/init.d/dropbear restart"

c_port $file_port dropbear1 $dropbear1
c_port $file_port dropbear2 $dropbear2
c_port $file_port dropbear3 $dropbear3

ufw allow $dropbear1 &>/dev/null
ufw allow $dropbear2 &>/dev/null
ufw allow $dropbear3 &>/dev/null

cd $home
