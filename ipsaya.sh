#!/bin/bash

msg -red "Semua Port TCP UDP Yang Aktif:"

ipv6aku=$(ip addr show eth0 | grep "inet6\b" | awk '{print $2}' | cut -d/ -f1)
ipv4aku=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
ipaku=$(wget -qO- ipecho.net/plain)
hostall=$(hostname --all-ip-addresses | awk '{print $0}')
host1=$(hostname --all-ip-addresses | awk '{print $1}')
host2=$(hostname --all-ip-addresses | awk '{print $2}')
host3=$(hostname --all-ip-addresses | awk '{print $2}')
host4=$(hostname --all-ip-addresses | awk '{print $2}')
ipcidr=$(ip -4 -o addr show eth0 | awk '{print $4}')
slporttcp=sudo lsof -nP -iTCP -sTCP:LISTEN
slportudp=sudo lsof -iUDP -P -n | egrep -v '(127|::1)'

msg -org "${slporttcp}"
msg -org "${slportudp}"
echo

msg -red "Alamat IPv6 internal anda adalah:"
msg -org "${ipv6aku}"
echo
msg -org "Alamat IPv4 internal/ Private anda adalah:"
msg -org "${ipv4aku}"
echo
msg -org "Alamat IPv4 eksternal/ Publik anda adalah:"
msg -org "${ipaku}"
echo
msg -line " Semua Host "
msg -org "${host0}"
msg -org "Host 1 adalah:"
msg -org "${host1}"
msg -org "Host 2 adalah:"
msg -org "${host2}"
msg -org "Host 3 adalah:"
msg -org "${host3}"
msg -org "Host 4 adalah:"
msg -org "${host4}"
msg -org "IP CIDR adalah:"
msg -org "${ipcidr}"
echo
