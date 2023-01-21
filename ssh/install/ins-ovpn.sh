#!/bin/bash
# SL
# ==========================================
# Color
. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)

# ==================================================
export DEBIAN_FRONTEND=noninteractive
OS=$(uname -m)
MYIP2="s/xxxxxxxxx/$IP/g"
itrfc=$(ip -o $itrfc -4 route show to default | awk '{print $5}')

# Install OpenVPN dan Easy-RSA
msg -line " Install openvpn "
msg -org "Membuat folder /etc/openvpn/"
mkdir -p /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/
msg -org "Mendownload OPENVPN"
wget https://${pssh}/vpn.zip &>/dev/null
unzip vpn.zip &>/dev/null && rm -f vpn.zip &>/dev/null
chown -R root:root /etc/openvpn/server/easy-rsa/ &>/dev/null

cd $home
mkdir -p /usr/lib/openvpn/
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so &>/dev/null

msg -warn "Menghidupkan service openvpn"
# nano /etc/default/openvpn
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn

# restart openvpn dan cek status openvpn
systemctl enable --now openvpn-server@server-tcp &>/dev/null
systemctl enable --now openvpn-server@server-udp &>/dev/null
cmd "/etc/init.d/openvpn restart"
/etc/init.d/openvpn status

# aktifkan ip4 forwarding
msg -org "Mengaktifkan ip_forward pada ipv4"
echo 1 >/proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Buat config client TCP 1194
msg -red "Membuat config untuk client di /etc/openvpn/tcp.ovpn"
cat >/etc/openvpn/tcp.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx $openvpn_tcp
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/tcp.ovpn

# Buat config client UDP 2200
cat >/etc/openvpn/udp.ovpn <<-END
client
dev tun
proto udp
remote xxxxxxxxx $openvpn_udp
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/udp.ovpn

# Buat config client SSL
cat >/etc/openvpn/ssl.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx $openvpn_ssl
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/ssl.ovpn

cd
# pada tulisan xxx ganti dengan alamat ip address VPS anda
cmd "/etc/init.d/openvpn restart"

# masukkan certificatenya ke dalam config client TCP 1194
echo '<ca>' >>/etc/openvpn/tcp.ovpn
cat /etc/openvpn/server/ca.crt >>/etc/openvpn/tcp.ovpn
echo '</ca>' >>/etc/openvpn/tcp.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( TCP 1194 )
cp /etc/openvpn/tcp.ovpn /home/vps/public_html/tcp.ovpn

# masukkan certificatenya ke dalam config client UDP 2200
echo '<ca>' >>/etc/openvpn/udp.ovpn
cat /etc/openvpn/server/ca.crt >>/etc/openvpn/udp.ovpn
echo '</ca>' >>/etc/openvpn/udp.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( UDP 2200 )
cp /etc/openvpn/udp.ovpn /home/vps/public_html/udp.ovpn

# masukkan certificatenya ke dalam config client SSL
echo '<ca>' >>/etc/openvpn/ssl.ovpn
cat /etc/openvpn/server/ca.crt >>/etc/openvpn/ssl.ovpn
echo '</ca>' >>/etc/openvpn/ssl.ovpn

# Copy config OpenVPN client ke home directory root agar mudah didownload ( SSL )
cp /etc/openvpn/ssl.ovpn /home/vps/public_html/ssl.ovpn

#firewall untuk memperbolehkan akses UDP dan akses jalur TCP

iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o $itrfc -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o $itrfc -j MASQUERADE
iptables-save >/etc/iptables.up.rules
chmod +x /etc/iptables.up.rules

iptables-restore -t </etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Restart service openvpn
cmd "systemctl enable openvpn"
cmd "systemctl start openvpn"
cmd "/etc/init.d/openvpn restart"

# Delete script
history -c

cd $home
