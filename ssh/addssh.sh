#!/bin/bash

# Getting

touch $file_config

cdndomain=$(cat /root/awscdndomain)
slkey=$(cat /etc/slowdns/server.pub)
clear

tanya "Username" Login
tanya "Password" Pass
tanya "Expired (Days)" masaaktif

IP=$(wget -qO- ipinfo.io/ip)

ws=$(cari_port $file_port vmess_tls)
ws2=$(cari_port $file_port vmess_nontls)

### ws="$(cat ./log-install.txt | grep -w "Websocket TLS" | cut -d: -f2 | sed 's/ //g')"
### ws2="$(cat ~/log-install.txt | grep -w "Websocket None TLS" | cut -d: -f2 | sed 's/ //g')"

ssl="$(cat ~/log-install.txt | grep -w "Stunnel5" | cut -d: -f2)"
ovpn="$(cek_port openvpn tcp)"
ovpn2="$(cek_port openvpn udp)"

c_port $file_port openvpn_tcp $ovpn
c_port $file_port openvpn_udp $ovpn2
clear

msg -warn "Stop Client SLDNS"
systemctl stop client-sldns &>/dev/null
pkill sldns-client &>/dev/null
systemctl disable client-sldns &>/dev/null
msg -warn "Stop Server SLDNS"
systemctl stop server-sldns &>/dev/null
pkill sldns-server &>/dev/null
systemctl disable server-sldns &>/dev/null

msg -warn "Start Client SLDNS"
systemctl enable client-sldns &>/dev/null
cmd "systemctl start client-sldns"
msg -warn "Start Server SLDNS"
systemctl enable server-sldns &>/dev/null
cmd "systemctl start server-sldns"

msg -warn "restart ws tls"
cmd "systemctl restart ws-tls"
msg -warn "restart ws nontls"
cmd "systemctl restart ws-nontls"
msg -warn "restart ssh ohp"
cmd "systemctl restart ssh-ohp"
msg -warn "restart dropbear ohp"
cmd "systemctl restart dropbear-ohp"
msg -warn "restart openvpn ohp"
cmd "systemctl restart openvpn-ohp"

useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login
expi="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
hariini=$(date -d "0 days" +"%Y-%m-%d")
expi=$(date -d "$masaaktif days" +"%Y-%m-%d")

ssh1=$(cari_port $file_port ssh1)
http1=$(cari_port $file_port http1)
dropbear1=$(cari_port $file_port dropbear1)
dropbear2=$(cari_port $file_port dropbear2)
dropbear3=$(cari_port $file_port dropbear3)
openvpn_ssl=$(cari_port $file_port openvpn_ssl)

touch $file_port
echo -e ""
echo -e "Informasi SSH & OpenVPN"
echo -e "=============================="
echo -e "Username: $Login"
echo -e "Password: $Pass"
echo -e "Created: $hariini"
echo -e "Expired: $expi"
echo -e "===========HOST-SSH==========="
echo -e "IP/Host: $IP"
echo -e "Domain SSH: $domain_vps"
echo -e "Domain Cloudflare: $domain_vps"
echo -e "Domain CloudFront: $cdndomain"
echo -e "===========SLOWDNS==========="
echo -e "Domain Name System(DNS): 8.8.8.8"
echo -e "Name Server(NS): $domain_slowdns"
echo -e "DNS PUBLIC KEY: $slkey"
echo -e "Domain SlowDNS: $domain_slowdns"
echo -e "=========Service-Port========="
echo -e "SlowDNS: 443,22,109,143"
echo -e "OpenSSH: $ssh1"
echo -e "Dropbear: $dropbear1, $dropbear2, $dropbear3"
echo -e "SSL/TLS: 443"
echo -e "SSH Websocket SSL/TLS: 443"
echo -e "SSH Websocket HTTP: $http1"
echo -e "BadVPN UDPGW: $badvpn1,$badvpn2,$badvpn3"
echo -e "Proxy CloudFront: [OFF]"
echo -e "Proxy Squid: [OFF]"
echo -e "OHP SSH: 8181"
echo -e "OHP Dropbear: 8282"
echo -e "OHP OpenVPN: 8383"
echo -e "OVPN Websocket: 2086"
echo -e "OVPN Port TCP: $ovpn"
echo -e "OVPN Port UDP: $ovpn2"
echo -e "OVPN Port SSL: $openvpn_ssl"
echo -e "OVPN TCP: http://$IP:$webserver_nginx/tcp.ovpn"
echo -e "OVPN UDP: http://$IP:$webserver_nginx/udp.ovpn"
echo -e "OVPN SSL: http://$IP:$webserver_nginx/ssl.ovpn"
echo -e "=============================="
echo -e "SNI/Server Spoof: isi dengan bug"
echo -e "Payload Websocket SSL/TLS"
echo -e "=============================="
echo -e "GET wss://bug.com/ HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]"
echo -e "=============================="
echo -e "Payload Websocket HTTP"
echo -e "=============================="
echo -e "GET / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]"
echo -e "=============================="
echo -e "Script Mod By SL"
