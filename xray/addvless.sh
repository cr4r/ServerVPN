#!/bin/bash
# SL
# ==========================================
. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
IZIN=$(curl ipinfo.io/ip | grep $IP)

if [ $IP = $IP ]; then
	msg -gr "Permission Accepted..."
else
	msg -warn "Permission Denied!"
	exit 0
fi
clear

source /var/lib/crot/ipvps.conf
if [[ "$IP" = "" ]]; then
	domain=$(cat /etc/xray/domain)
else
	domain=$IP
fi

source /etc/xray/port
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
	read -p $(msg -ne "Username : ") user
	CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

	if [[ ${CLIENT_EXISTS} == '1' ]]; then
		msg -warn "Username $(msg -gr user) Already On VPS Please Choose Another"
		exit 1
	fi
done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
hariini=$(date -d "0 days" +"%Y-%m-%d")
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
sed -i '/#xray-vless-tls$/a\#### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#xray-vless-nontls$/a\#### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
xrayvless1="vless://${uuid}@${domain}:$tls?path=/vless/&security=tls&encryption=none&type=ws#${user}"
xrayvless2="vless://${uuid}@${domain}:$nontls?path=/vless/&encryption=none&type=ws#${user}"
systemctl restart xray.service
service cron restart
clear
echo -e ""
echo -e "======-XRAYS/VLESS-======"
echo -e "Remarks     : ${user}"
echo -e "IP/Host     : ${IP}"
echo -e "Address     : ${domain}"
echo -e "Port TLS    : $tls"
echo -e "Port No TLS : $nontls"
echo -e "User ID     : ${uuid}"
echo -e "Encryption  : none"
echo -e "Network     : ws"
echo -e "Path        : /vless/"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "========================="
echo -e "Link TLS    : ${xrayvless1}"
echo -e "========================="
echo -e "Link No TLS : ${xrayvless2}"
echo -e "========================="
echo -e "Script Mod By SL"
