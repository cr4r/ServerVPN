#!/bin/bash
(
	if [ "${EUID}" -ne 0 ]; then
		echo "Pengguna harus mode root"
		exit 1
	fi
	if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
	fi

	echo "sudo apt-get update&&sudo apt-get upgrade -y&&sudo apt-get dist-upgrade -y&&sudo apt-get autoremove -y" >/bin/update && sudo chmod 777 /bin/update

	# Link Hosting
	. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)
	rm -rf $home &>/dev/null

	mkdir -p $home && cd $home

	msg -warn "Install dan menghidupkan Firewall (UFW)!"
	inst_comp ufw
	ufw allow http &>/dev/null
	ufw allow http &>/dev/nulls &>/dev/null
	ufw allow ssh &>/dev/null
	ufw enable &>/dev/null

	# ==========================================
	# Color
	RED='\033[0;31m'
	NC='\033[0m'
	GREEN='\033[0;32m'
	ORANGE='\033[0;33m'
	BLUE='\033[0;34m'
	PURPLE='\033[0;35m'
	CYAN='\033[0;36m'
	LIGHT='\033[0;37m'
	# Getting
	clear

	msg -line "Selamat Datang"
	msg -warn "Semua aktivitas tercatat di /tmp/setupVPN.log"
	msg -warn "Firewal dari UFW telah di aktifkan!"
	msg -org "IP Server: $(msg -red $IP)"

	## if [ -f "/etc/xray/domain" ]; then
	## 	echo "Script Already Installed"
	## 	exit 0
	## fi

	mkdir -p /var/lib/crot
	echo "IP=" >>/var/lib/crot/ipvps.conf
	msg -line " Seting Domain VPS "
	. <(curl -s ${pssh}/slhost.sh) ### Sudah Fix
	# # . ${HomeRepo}/ssh/slhost.sh

	msg -line " Install XRAY "
	. <(curl -s ${pxray}/ins-xray.sh) ### Sudah Fix
	# . ${HomeRepo}/xray/ins-xray.sh

	# #install ssh ovpn ###############################################>
	msg -line " Install ssh ovpn "
	# . <(curl -s ${pssh}/ssh-vpn.sh) ### Belum Fix
	. ${pssh}/ssh-vpn.sh

	# wget ${psstp}/sstp.sh && chmod +x sstp.sh && screen -S sstp ./sstp.sh
	# #install ssr
	# wget ${pssr}/ssr.sh && chmod +x ssr.sh && screen -S ssr ./ssr.sh
	# wget ${psocks}/sodosok.sh && chmod +x sodosok.sh && screen -S ss ./sodosok.sh
	# #installwg
	# wget ${pwrguard}/wg.sh && chmod +x wg.sh && screen -S wg ./wg.sh
	# #install L2TP
	# wget ${pipsec}/ipsec.sh && chmod +x ipsec.sh && screen -S ipsec ./ipsec.sh
	# wget ${pbackup}/set-br.sh && chmod +x set-br.sh && ./set-br.sh
	# # Websocket
	# wget ${pwst}/edu.sh && chmod +x edu.sh && ./edu.sh
	# # Ohp Server
	# wget ${pohp}/ohp.sh && chmod +x ohp.sh && ./ohp.sh
	# Install SlowDNS
	# . <(curl -s ${psldns}/install-sldns.sh) ### Belum Fix
	# . ${HomeRepo}/SLDNS/install-sldns

	# # Informasi IP Saya dan Semua Port TCP UDP
	. <(curl -s ${rawRepo}/ipsaya.sh) ### Sudah Fix

	# # install xray sl-grpc
	# # wget https://raw.githubusercontent.com/cr4r/ServerVPN/main/grpc/sl-grpc.sh && chmod +x sl-grpc.sh && screen -S sl-grpc ./sl-grpc.sh
	# # install xray grpc
	# # wget https://raw.githubusercontent.com/cr4r/ServerVPN/main/grpc/xray-grpc.sh && chmod +x xray-grpc.sh && screen -S xray-grpc ./xray-grpc.sh
	# # install shadowsocks plugin
	# # wget https://raw.githubusercontent.com/cr4r/ServerVPN/main/shadowsocks-plugin/install-ss-plugin.sh && chmod +x install-ss-plugin.sh && ./install-ss-plugin.sh

	history -c
	echo "1.2" >/$home/ver
	cd $home
	echo " "
	echo "Installation has been completed!!"
	echo "============================================================================" | tee -a log-install.txt
	echo "" | tee -a log-install.txt
	echo "----------------------------------------------------------------------------" | tee -a log-install.txt
	echo "" | tee -a log-install.txt
	echo "   >>> Service & Port" | tee -a log-install.txt
	echo "   - SlowDNS SSH             : ALL Port SSH" | tee -a log-install.txt
	echo "   - OpenSSH                 : 22, 2253" | tee -a log-install.txt
	echo "   - OpenVPN                 : TCP 1194, UDP 2200, SSL 990" | tee -a log-install.txt
	echo "   - Stunnel5                : 443, 445" | tee -a log-install.txt
	# echo "   - Dropbear                : 443, 109, 143" | tee -a log-install.txt
	echo "   - CloudFront Websocket    : " | tee -a log-install.txt
	echo "   - SSH Websocket TLS       : 443" | tee -a log-install.txt
	echo "   - SSH Websocket HTTP      : 8880" | tee -a log-install.txt
	echo "   - Websocket OpenVPN       : 2086" | tee -a log-install.txt
	# echo "   - Squid Proxy             : 3128, 8080" | tee -a log-install.txt
	echo "   - Badvpn                  : 7100, 7200, 7300" | tee -a log-install.txt
	echo "   - Nginx                   : 89" | tee -a log-install.txt
	# echo "   - Wireguard               : 7070" | tee -a log-install.txt
	# echo "   - L2TP/IPSEC VPN          : 1701" | tee -a log-install.txt
	# echo "   - PPTP VPN                : 1732" | tee -a log-install.txt
	# echo "   - SSTP VPN                : 444" | tee -a log-install.txt
	# echo "   - Shadowsocks-R           : 1443-1543" | tee -a log-install.txt
	# echo "   - SS-OBFS TLS             : 2443-2543" | tee -a log-install.txt
	# echo "   - SS-OBFS HTTP            : 3443-3543" | tee -a log-install.txt
	echo "   - XRAYS Vmess TLS         : 8443" | tee -a log-install.txt
	echo "   - XRAYS Vmess None TLS    : 80" | tee -a log-install.txt
	echo "   - XRAYS Vless TLS         : 8443" | tee -a log-install.txt
	echo "   - XRAYS Vless None TLS    : 80" | tee -a log-install.txt
	echo "   - XRAYS Trojan            : 2083" | tee -a log-install.txt
	# echo "   - XRAYS VMESS GRPC        : 1180" | tee -a log-install.txt
	# echo "   - XRAYS VLESS GRPC        : 2280" | tee -a log-install.txt
	# echo "   - OHP SSH                 : 8181" | tee -a log-install.txt
	# echo "   - OHP Dropbear            : 8282" | tee -a log-install.txt
	# echo "   - OHP OpenVPN             : 8383" | tee -a log-install.txt
	# echo "   - TrojanGo                : 2087" | tee -a log-install.txt
	echo "" | tee -a log-install.txt
	echo "   >>> Server Information & Other Features" | tee -a log-install.txt
	echo "   - Timezone                : Asia/Jakarta (GMT +7)" | tee -a log-install.txt
	echo "   - Fail2Ban                : [ON]" | tee -a log-install.txt
	echo "   - Dflate                  : [ON]" | tee -a log-install.txt
	echo "   - IPtables                : [ON]" | tee -a log-install.txt
	echo "   - Auto-Reboot             : [ON]" | tee -a log-install.txt
	echo "   - IPv6                    : [OFF]" | tee -a log-install.txt
	echo "   - Autoreboot On 05.00 GMT +7" | tee -a log-install.txt
	echo "   - Autobackup Data" | tee -a log-install.txt
	echo "   - Restore Data" | tee -a log-install.txt
	echo "   - Auto Delete Expired Account" | tee -a log-install.txt
	echo "   - Full Orders For Various Services" | tee -a log-install.txt
	echo "   - White Label" | tee -a log-install.txt
	echo "   - Installation Log --> /root/log-install.txt" | tee -a log-install.txt
	echo " Reboot 5 Sec"
	sleep 5
	# reboot
) 2>&1 | tee -a /tmp/setupVPN.log
