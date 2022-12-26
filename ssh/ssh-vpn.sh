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

#detail nama perusahaan
country=ID
state=Indonesia
locality=Indonesia
organization=codersfamily
organizationalunit=codersfamily
commonname=codersfamily
email=cr4rrr@gmail.com

. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)

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

# install webserver
msg -line " Menginstall Web Server "
msg -org "Menghapus /etc/nginx/sites-enabled/default"
rm /etc/nginx/sites-enabled/default
msg -org "Menghapus /etc/nginx/sites-available/default"
rm /etc/nginx/sites-available/default
msg -org "Membuat konfigurasi pada /etc/nginx/nginx.conf"
curl ${pssh}/nginx.conf >/etc/nginx/nginx.conf &>/dev/null
msg -org "Membuat konfigurasi pada /etc/nginx/conf.d/vps.conf"
curl ${pssh}/vps.conf >/etc/nginx/conf.d/vps.conf &>/dev/null
msg -org "sed -i 's/listen = \/var\/run\/php-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/fpm/pool.d/www.conf"
sed -i 's/listen = \/var\/run\/php-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/fpm/pool.d/www.conf
msg -red "Membuat user *vps*"
useradd -m vps &>/dev/null
msg -org "Membuat folder /home/vps/public_html"
mkdir -p /home/vps/public_html
msg -org "echo \"<?php phpinfo() ?>\" >/home/vps/public_html/info.php"
echo "<?php phpinfo() ?>" >/home/vps/public_html/info.php &>/dev/null
msg -org "chown -R www-data:www-data /home/vps/public_html"
chown -R www-data:www-data /home/vps/public_html &>/dev/null
msg -org "chmod -R g+rw /home/vps/public_html"
chmod -R g+rw /home/vps/public_html &>/dev/null
msg -org "Menuju ke /home/vps/public_html"
cd /home/vps/public_html
msg -org "wget -O /home/vps/public_html/index.html "${pssh}/index.html1""
wget -O /home/vps/public_html/index.html "${pssh}/index.html1" &>/dev/null
msg -warn "Restart Nginx"
cmd "/etc/init.d/nginx restart"
cd $home

# install badvpn
msg -line " Menginstall badvpn "
msg -org "Mengunduh dan membuat permission badvpn-udpgw"
wget -O /usr/bin/badvpn-udpgw "${pssh}/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw

maxClientBadVPN=500
msg -warn "Menjalankan badvpn dengan port 7100, 7200, 7300 dengan max client ${maxClientBadVPN}"

sed -i "$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients $maxClientBadVPN" /etc/rc.local &>/dev/null
sed -i "$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients $maxClientBadVPN" /etc/rc.local &>/dev/null
sed -i "$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients $maxClientBadVPN" /etc/rc.local &>/dev/null

screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients $maxClientBadVPN &>/dev/null
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients $maxClientBadVPN &>/dev/null
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients $maxClientBadVPN &>/dev/null

msg -red "Seting ufw port 7100, 7200, 7300 untuk udpgw"
ufw allow 7100 &>/dev/null
ufw allow 7200 &>/dev/null
ufw allow 7300 &>/dev/null

# setting port ssh
msg -warn "Seting Port ssh ke 22,2253,42"
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config &>/dev/null
sed -i '/Port 22/a Port 2253' /etc/ssh/sshd_config &>/dev/null
echo "Port 22" >>/etc/ssh/sshd_config &>/dev/null
echo "Port 42" >>/etc/ssh/sshd_config &>/dev/null
cmd "/etc/init.d/ssh restart"

msg -red "Seting ufw port 22, 2253, 42 untuk ssh"
ufw allow 22 &>/dev/null
ufw allow 2253 &>/dev/null
ufw allow 42 &>/dev/null

# # install dropbear
# msg -line " Setting DropBear "
# msg -org "sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear"
# sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear &>/dev/null
# msg -org "sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear"
# sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear &>/dev/null
# msg -org "sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS=\"-p 109 -p 1153\"/g' /etc/default/dropbear"
# sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 1153"/g' /etc/default/dropbear &>/dev/null
# msg -org "echo \"/bin/false\" >>/etc/shells"
# echo "/bin/false" >>/etc/ &>/dev/null
# msg -org "echo \"/usr/sbin/nologin\" >>/etc/shells"
# echo "/usr/sbin/nologin" >>/etc/shells &>/dev/null
# msg -org "Restart DropBear"
# cmd "/etc/init.d/dropbear restart" &>/dev/null

# install squid (proxy nya aku matikan)
cd $home
#apt -y install squid3
#wget -O /etc/squid/squid.conf "${pssh}/squid3.conf"
#sed -i $IP2 /etc/squid/squid.conf

# Settings SSLH
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

	DAEMON_OPTS="--user sslh --listen 0.0.0.0:443 --ssl 127.0.0.1:777 --ssh 127.0.0.1:109 --openvpn 127.0.0.1:1194 --http 127.0.0.1:8880 --pidfile /var/run/sslh/sslh.pid -n"
END

msg -red "Seting port 443, 777, 109, 1194, 8880 untuk SSLH di UFW"
ufw allow 443 &>/dev/null
ufw allow 777 &>/dev/null
ufw allow 109 &>/dev/null
ufw allow 1194 &>/dev/null
ufw allow 8880 &>/dev/null

# Restart Service SSLH
msg -org "Restart Service SSLH"
cmd "service sslh restart" &>/dev/null
cmd "systemctl restart sslh" &>/dev/null
cmd "/etc/init.d/sslh restart" &>/dev/null
cmd "/etc/init.d/sslh status" &>/dev/null
cmd "/etc/init.d/sslh restart" &>/dev/null

msg -line " Setting vnstat "
cd $home
# setting vnstat
cmd "/etc/init.d/vnstat restart" &>/dev/null
msg -org "Sedang mengupdate vnstat"
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz &>/dev/null
tar zxvf vnstat-2.6.tar.gz &>/dev/null

msg -warn "Sedang build vnstat, mungkin membutuhkan waktu lama"
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc &>/dev/null
make &>/dev/null
make install &>/dev/null
cd $home
msg -org "Konfigurasi vnstat"
vnstat -u -i $NET &>/dev/null
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf &>/dev/null
chown vnstat:vnstat /var/lib/vnstat -R &>/dev/null
msg -org "Start VNSTAT"
systemctl enable vnstat &>/dev/null
/etc/init.d/vnstat restart &>/dev/null
rm -rf $home/vnstat-2.6 $home/vnstat-2.6.tar.gz &>/dev/null

### install stunnel 5
msg -line " Instalasi Stunnel "
cd $home
msg -org "Download Stunnel"
wget -q -O stunnel5.zip "${pstunnel5}/stunnel5.zip" &>/dev/nul && unzip -o stunnel5.zip &>/dev/nul
msg -org "Build Stunnel, mungkin membutuhkan waktu lama"
cd $home/stunnel && chmod +x configure && ./configure &>/dev/null
make &>/dev/null && make install &>/dev/null
cd $home && rm -rf stunnel stunnel5.zip &>/dev/null && mkdir -p /etc/stunnel5 && chmod 644 /etc/stunnel5

cat >/etc/stunnel5/stunnel5.conf <<-END
	cert = /etc/xray/xray.crt
	key = /etc/xray/xray.key
	client = no
	socket = a:SO_REUSEADDR=1
	socket = l:TCP_NODELAY=1
	socket = r:TCP_NODELAY=1

	# [dropbear]
	# accept = 445
	# connect = 127.0.0.1:109

	[openssh]
	accept = 777
	connect = 127.0.0.1:443

	[openvpn]
	accept = 990
	connect = 127.0.0.1:1194

END

### make a certificate
msg -gr "Membuat sertifikat untuk stunnel5"
openssl genrsa -out key.pem 2048 &>/dev/null
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
	-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email" &>/dev/null
msg -gr "Copy ke /etc/stunnel5/stunnel5.pem"
cat key.pem cert.pem >>/etc/stunnel5/stunnel5.pem &>/dev/null

### Restart Service Stunnel5
cmd "systemctl restart stunnel5"
cat >/etc/systemd/system/stunnel5.service <<END
[Unit]
Description=Stunnel5 Service
Documentation=https://stunnel.org
Documentation=https://github.com/cr4r
After=syslog.target network-online.target

[Service]
ExecStart=/usr/local/bin/stunnel5 /etc/stunnel5/stunnel5.conf
Type=forking

[Install]
WantedBy=multi-user.target
END

# # Service Stunnel5 /etc/init.d/stunnel5
cmd "wget -q -O /etc/init.d/stunnel5 ${pstunnel5}/stunnel5.init"

### Ubah Izin Akses
chmod 600 /etc/stunnel5/stunnel5.pem &>/dev/null
chmod +x /etc/init.d/stunnel5 &>/dev/null
cp /usr/local/bin/stunnel /usr/local/bin/stunnel5 &>/dev/null

### Restart Stunnel 5
cmd "systemctl stop stunnel5"
cmd "systemctl enable stunnel5"
cmd "systemctl start stunnel5"

### OpenVPN
. <(curl -s ${pssh}/vpn.sh)

mkdir -p /usr/local/ddos

### banner /etc/issue.net
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

### Install BBR
. <(curl -s ${pssh}/bbr.sh)

### Ganti Banner
wget -O /etc/issue.net "${pssh}/issue.net"

### blockir torrent
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
# wget -O slhost "${pssh}/slhost.sh"
# wget -O about "${pssh}/about.sh"
# wget -O menu "${rawRepo}/update/menu.sh"
# wget -O addssh "${pssh}/addssh.sh"
# wget -O trialssh "${pssh}/trialssh.sh"
# wget -O delssh "${pssh}/delssh.sh"
# wget -O member "${pssh}/member.sh"
# wget -O delexp "${pssh}/delexp.sh"
# wget -O cekssh "${pssh}/cekssh.sh"
# wget -O restart "${pssh}/restart.sh"
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
