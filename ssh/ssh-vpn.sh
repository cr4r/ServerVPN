#!/bin/bash
# ==========================================
# Color
NC='\033[0m'
# ==================================================

# initializing var
export DEBIAN_FRONTEND=noninteractive
# MYIP2="s/xxxxxxxxx/$IP/g"

source /etc/os-release
ver=$VERSION_ID

. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)
### export port yang dibutuhkan
. <(curl -s ${rawRepo}/port)

# simple password minimal
wget -O /etc/pam.d/common-password "${pssh}/password" &>/dev/null
chmod +x /etc/pam.d/common-password &>/dev/null

# go to root
cd $home

# Edit file /etc/systemd/system/rc-local.service
msg -red "Membuat default pada /etc/systemd/system/rc-local.service"
cat >/etc/systemd/system/rc-local.service <<-END
	[Unit]
	Description=/etc/rc.local
	ConditionPathExists=/etc/rc.local
	[Service]
	Type=forking
	ExecStart=/etc/rc.local start
	TimeoutSec=0
	StandardOutput=tty
	RemainAfterExit=yes
	SysVStartPriority=99
	[Install]
	WantedBy=multi-user.target
END

# nano /etc/rc.local
msg -red "Membuat default /etc/rc.local"
cat >/etc/rc.local <<-END
	#!/bin/sh -e
	# rc.local
	# By default this script does nothing.
	exit 0
END

# Ubah izin akses
msg -org "Memberi akses +x pada rc.local"
chmod +x /etc/rc.local &>/dev/null

# enable rc local
msg -warn "Enable rc local"
systemctl enable rc-local &>/dev/null
msg -org "Memulai rc local"
cmd "systemctl start rc-local.service"

# disable ipv6
msg -warn "Mematikan fungsi IPV6 pada server"
echo 1 >/proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#update
msg -red "Sedang memperbarui system"
update &>/dev/null

install_all_component $(curl -Ls $urlFile/main/ssh/plugin)

ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

echo "clear" >>.profile
echo "neofetch" >>.profile

linkinstall="${pssh}/install"

# setting port ssh
msg -warn "Seting Port ssh ke 22,2253,42"
### Mengembalikan sshd default
msg -warn "Restore default sshd_config"
cp /usr/share/openssh/sshd_config /etc/ssh/sshd_config &>/dev/null

### Membuat port ssh lain
sed -i "/#Port/Port" /etc/ssh/sshd_config &>/dev/null
### Menambahkan port baru di bawah port 22
sed -i "/Port 22/a Port ${ssh2}" /etc/ssh/sshd_config &>/dev/null
### Menambahkan port baru di bawah port ssh2
sed -i "/Port ${ssh2}/a Port ${ssh3}" /etc/ssh/sshd_config &>/dev/null
cmd "/etc/init.d/ssh restart"

msg -red "Seting ufw port $ssh1, $ssh2, $ssh3 untuk ssh"
ufw allow $ssh1 &>/dev/null
ufw allow $ssh2 &>/dev/null
ufw allow $ssh3 &>/dev/null

c_port $file_port ssh1 $ssh1
c_port $file_port ssh2 $ssh2
c_port $file_port ssh3 $ssh3

### install webserver
. <(curl -s ${linkinstall}/ins-webserver.sh)

### install badvpn
. <(curl -s ${linkinstall}/ins-badvpn.sh)

### install vnstat
. <(curl -s ${linkinstall}/ins-vnstat.sh)

### install dropbear
. <(curl -s ${linkinstall}/ins-dropbear.sh)

### OpenVPN
. <(curl -s ${linkinstall}/inst-ovpn.sh)

### install stunnel5
. <(curl -s ${linkinstall}/inst-stunnel5.sh)

# Settings SSLH
. <(curl -s ${linkinstall}/ins-sslh.sh)

mkdir -p /usr/local/ddos

### banner /etc/issue.net
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

### Install BBR
. <(curl -s ${pssh}/bbr.sh)

### Ganti Banner
wget -O /etc/issue.net "${pssh}/issue.net"

### block torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save >/etc/iptables.up.rules
iptables-restore -t </etc/iptables.up.rules
netfilter-persistent save &>/dev/null
netfilter-persistent reload &>/dev/null

### download script
cd /usr/bin
wget -O addhost "${pssh}/addhost.sh"
wget -O slhost "${pssh}/slhost.sh"
wget -O about "${pssh}/about.sh"
wget -O menu "${rawRepo}/update/menu.sh"
wget -O addssh "${pssh}/addssh.sh"
wget -O trialssh "${pssh}/trialssh.sh"
wget -O delssh "${pssh}/delssh.sh"
wget -O member "${pssh}/member.sh"
wget -O delexp "${pssh}/delexp.sh"
wget -O cekssh "${pssh}/cekssh.sh"
wget -O restart "${pssh}/restart.sh"
# wget -O speedtest "${pssh}/speedtest_cli.py"
# wget -O info "${pssh}/info.sh"
# wget -O ram "${pssh}/ram.sh"
# wget -O renewssh "${pssh}/renewssh.sh"
# wget -O autokill "${pssh}/autokill.sh"
# wget -O ceklim "${pssh}/ceklim.sh"
# wget -O tendang "${pssh}/tendang.sh"
# wget -O clearlog "${pssh}/clearlog.sh"
# wget -O changeport "${pssh}/changeport.sh"
# wget -O portovpn "${pssh}/portovpn.sh"
# wget -O portwg "${pssh}/portwg.sh"
# wget -O porttrojan "${pssh}/porttrojan.sh"
# wget -O portsstp "${pssh}/portsstp.sh"
# wget -O portsquid "${pssh}/portsquid.sh"
# wget -O portvlm "${pssh}/portvlm.sh"
# wget -O wbmn "${pssh}/webmin.sh"
# wget -O xp "${pssh}/xp.sh"
# wget -O swapkvm "${pssh}/swapkvm.sh"
# wget -O addvmess "${pxray}/addv2ray.sh"
# wget -O addvless "${pxray}/addvless.sh"
# wget -O addtrojan "${pxray}/addtrojan.sh"
# wget -O addgrpc "${pxray}/addgrpc.sh"
# wget -O cekgrpc "${pxray}/cekgrpc.sh"
# wget -O delgrpc "${pxray}/delgrpc.sh"
# wget -O renewgrpc "${pxray}/renewgrpc.sh"
# wget -O delvmess "${pxray}/delv2ray.sh"
# wget -O delvless "${pxray}/delvless.sh"
# wget -O deltrojan "${pxray}/deltrojan.sh"
# wget -O cekvmess "${pxray}/cekv2ray.sh"
# wget -O cekvless "${pxray}/cekvless.sh"
# wget -O cektrojan "${pxray}/cektrojan.sh"
# wget -O renewvmess "${pxray}/renewv2ray.sh"
# wget -O renewvless "${pxray}/renewvless.sh"
# wget -O renewtrojan "${pxray}/renewtrojan.sh"
# wget -O certv2ray "${pxray}/certv2ray.sh"
# wget -O addtrgo "${ptrojango}/addtrgo.sh"
# wget -O deltrgo "${ptrojango}/deltrgo.sh"
# wget -O renewtrgo "${ptrojango}/renewtrgo.sh"
# wget -O cektrgo "${ptrojango}/cektrgo.sh"
# wget -O portsshnontls "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/websocket/portsshnontls.sh"
# wget -O portsshws "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/websocket/portsshws.sh"

# wget -O ipsaya "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/ipsaya.sh"
# wget -O sshovpnmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/sshovpn.sh"
# wget -O l2tpmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/l2tpmenu.sh"
# wget -O pptpmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/pptpmenu.sh"
# wget -O sstpmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/sstpmenu.sh"
# wget -O wgmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/wgmenu.sh"
# wget -O ssmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/ssmenu.sh"
# wget -O ssrmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/ssrmenu.sh"
# wget -O vmessmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/vmessmenu.sh"
# wget -O vlessmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/vlessmenu.sh"
# wget -O grpcmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/grpcmenu.sh"
# wget -O grpcupdate "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/grpcupdate.sh"
# wget -O trmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/trmenu.sh"
# wget -O trgomenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/trgomenu.sh"
# wget -O setmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/setmenu.sh"
# wget -O slowdnsmenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/slowdnsmenu.sh"
# wget -O running "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/running.sh"
# wget -O updatemenu "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/update/updatemenu.sh"
# wget -O sl-fix "https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/sslh-fix/sl-fix"

# chmod +x sl-fix
# chmod +x ipsaya
# chmod +x sshovpnmenu
# chmod +x l2tpmenu
# chmod +x pptpmenu
# chmod +x sstpmenu
# chmod +x wgmenu
# chmod +x ssmenu
# chmod +x ssrmenu
# chmod +x vmessmenu
# chmod +x vlessmenu
# chmod +x grpcmenu
# chmod +x grpcupdate
# chmod +x trmenu
# chmod +x trgomenu
# chmod +x setmenu
# chmod +x slowdnsmenu
# chmod +x running
# chmod +x updatemenu

# chmod +x portsshnontls
# chmod +x portsshws

# chmod +x slhost
# chmod +x addhost
# chmod +x menu
# chmod +x addssh
# chmod +x trialssh
# chmod +x delssh
# chmod +x member
# chmod +x delexp
# chmod +x cekssh
# chmod +x restart
# chmod +x speedtest
# chmod +x info
# chmod +x about
# chmod +x autokill
# chmod +x tendang
# chmod +x ceklim
# chmod +x ram
# chmod +x renewssh
# chmod +x clearlog
# chmod +x changeport
# chmod +x portovpn
# chmod +x portwg
# chmod +x porttrojan
# chmod +x portsstp
# chmod +x portsquid
# chmod +x portvlm
# chmod +x wbmn
# chmod +x xp
# chmod +x swapkvm
# chmod +x addvmess
# chmod +x addvless
# chmod +x addtrojan
# chmod +x addgrpc
# chmod +x delgrpc
# chmod +x delvmess
# chmod +x delvless
# chmod +x deltrojan
# chmod +x cekgrpc
# chmod +x cekvmess
# chmod +x cekvless
# chmod +x cektrojan
# chmod +x renewgrpc
# chmod +x renewvmess
# chmod +x renewvless
# chmod +x renewtrojan
# chmod +x certv2ray
# chmod +x addtrgo
# chmod +x deltrgo
# chmod +x renewtrgo
# chmod +x cektrgo
# echo "0 5 * * * root clearlog && reboot" >>/etc/crontab
# echo "0 0 * * * root xp" >>/etc/crontab
# echo "0 1 * * * root delexp" >>/etc/crontab
# echo "10 4 * * * root clearlog && sslh-fix-reboot" >>/etc/crontab
# echo "0 0 * * * root clearlog && reboot" >>/etc/crontab
# echo "0 12 * * * root clearlog && reboot" >>/etc/crontab
# echo "0 18 * * * root clearlog && reboot" >>/etc/crontab

# # remove unnecessary files
# cd
# apt autoclean -y
# apt -y remove --purge unscd
# apt-get -y --purge remove samba*
# apt-get -y --purge remove apache2*
# apt-get -y --purge remove bind9*
# apt-get -y remove sendmail*
# apt autoremove -y
# # finishing
# cd
# chown -R www-data:www-data /home/vps/public_html
# /etc/init.d/nginx restart
# /etc/init.d/openvpn restart
# /etc/init.d/cron restart
# /etc/init.d/ssh restart
# /etc/init.d/dropbear restart
# /etc/init.d/fail2ban restart
# /etc/init.d/sslh restart
# /etc/init.d/stunnel5 restart
# /etc/init.d/vnstat restart
# /etc/init.d/fail2ban restart
# /etc/init.d/squid restart
# screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
# screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
# screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
# history -c
# echo "unset HISTFILE" >>/etc/profile

# cd
# rm -f /root/key.pem
# rm -f /root/cert.pem
# rm -f /root/ssh-vpn.sh

# # finihsing
# clear
