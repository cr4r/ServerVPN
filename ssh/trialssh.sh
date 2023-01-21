#!/bin/bash
# SL
# ==========================================
. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)

# source /var/crot/ipvps.conf
domain=$(cat /etc/xray/domain)
clear

ssl="$(cat ~/log-install.txt | grep -w "Stunnel5" | cut -d: -f2)"
sqd="$(cat ~/log-install.txt | grep -w "Squid" | cut -d: -f2)"
ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
Login=$(tr </dev/urandom -dc X-Z0-9 | head -c4)
hari="1"
Pass=1
clear
systemctl restart ws-tls
systemctl restart ws-nontls
systemctl restart ssh-ohp
systemctl restart dropbear-ohp
systemctl restart openvpn-ohp
useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
hariini=$(date -d "0 days" +"%Y-%m-%d")
expi=$(date -d "$masaaktif days" +"%Y-%m-%d")

ssh1=$(cari_port $file_port ssh1)
ssl1=$(cari_port $file_port ssh1)
http1=$(cari_port $file_port http1)
dropbear1=$(cari_port $file_port dropbear1)
dropbear2=$(cari_port $file_port dropbear2)
dropbear3=$(cari_port $file_port dropbear3)
badvpn1=$(cari_port $file_port badvpn1)
badvpn2=$(cari_port $file_port badvpn2)
badvpn3=$(cari_port $file_port badvpn3)
openvpn_ssl=$(cari_port $file_port openvpn_ssl)
ovpn_tcp="$(cek_port $file_port openvpn_tcp)"
ovpn_udp="$(cek_port $file_port openvpn_udp)"
ovpn_ssl="$(cek_port $file_port ovpn_ssl)"
webserver_nginx="$(cek_port $file_port webserver_nginx)"

echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
echo -e ""
echo -e "Informasi Trial SSH & OpenVPN"
echo -e "================================"
echo -e "IP/Host            : $IP"
echo -e "Domain             : $domain"
echo -e "Username           : $Login"
echo -e "Password           : $Pass"
echo -e "OpenSSH            : $ssh1"
echo -e "Dropbear           : $dropbear1, $dropbear2, $dropbear3"
echo -e "SSL/TLS            : $ssl1"
echo -e "Port Squid         : $sqd"
echo -e "OHP SSH            : 8181"
echo -e "OHP Dropbear       : 8282"
echo -e "OHP OpenVPN        : 8383"
echo -e "SSH Websocket SSL  : 443"
echo -e "SSH Websocket HTTP : $http1"
echo -e "OVPN Websocket     : 2086"
echo -e "OVPN Port TCP      : $ovpn"
echo -e "OVPN Port UDP      : $ovpn2"
echo -e "OVPN Port SSL      : $ovpn_ssl"
echo -e "OVPN TCP           : http://$IP:$webserver_nginx/tcp.ovpn"
echo -e "OVPN UDP           : http://$IP:$webserver_nginx/udp.ovpn"
echo -e "OVPN SSL           : http://$IP:$webserver_nginx/ssl.ovpn"
echo -e "BadVpn             : $badvpn1,$badvpn2,$badvpn3"
echo -e "Created            : $hariini"
echo -e "Expired            : $expi"
echo -e "=============================="
echo -e "Payload Websocket SSL/TLS"
echo -e "=============================="
echo -e "GET wss://bug.com [protocol][crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "=============================="
echo -e "Payload Websocket HTTP"
echo -e "=============================="
echo -e "GET / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "=============================="
