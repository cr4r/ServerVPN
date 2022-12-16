#!/bin/bash
. config

clear

ipv6aku=$(ip addr show eth0 | grep "inet6\b" | awk '{print $2}' | cut -d/ -f1)
ipv4aku=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
ipaku=$(wget -qO- ipecho.net/plain)
hostall=$(hostname --all-ip-addresses | awk '{print $0}')
host1=$(hostname --all-ip-addresses | awk '{print $1}')
host2=$(hostname --all-ip-addresses | awk '{print $2}')
host3=$(hostname --all-ip-addresses | awk '{print $2}')
host4=$(hostname --all-ip-addresses | awk '{print $2}')
ipcidr=$(ip -4 -o addr show eth0 | awk '{print $4}')

msg -org "Semua Port TCP UDP Yang Aktif:"
msg -line
slporttcp=sudo lsof -nP -iTCP -sTCP:LISTEN
msg -line
slportudp=sudo lsof -iUDP -P -n | egrep -v '(127|::1)'

msg -line
msg -org "Alamat IPv6 internal anda adalah:"
msg -gr "$ipv6aku"
echo

msg -org "Alamat IPv4 internal/ Private anda adalah:"
msg -warn "$ipv4aku"
echo

msg -org "Alamat IPv4 eksternal/ Publik anda adalah:"
msg -gr "$ipaku"
echo

msg -org "Semua Host adalah:"
msg -gr "$host0"
msg -org "Host 1 adalah:"
msg -gr "$host1"
msg -org "Host 2 adalah:"
msg -gr "$host2"
msg -org "Host 3 adalah:"
msg -gr "$host3"
msg -org "Host 4 adalah:"
msg -gr "$host4"
msg -org "IP CIDR adalah:"
msg -gr "$ipcidr"
msg -line
