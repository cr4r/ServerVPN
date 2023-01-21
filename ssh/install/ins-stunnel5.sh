#!/bin/bash

#detail nama perusahaan
country=ID
state=Indonesia
locality=Indonesia
organization=codersfamily
organizationalunit=codersfamily
commonname=codersfamily
email=cr4rrr@gmail.com

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

	[dropbear]
	accept = $dropbear1
	connect = 127.0.0.1:$dropbear2

	[openssh]
	accept = 777
	connect = 127.0.0.1:$openssh

	[openvpn]
	accept = $openvpn_ssl
	connect = 127.0.0.1:$openvpn_tcp

END

c_port $file_port stunnel $portTLS

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

c_port $file_port stunnel51 $stunnel51
c_port $file_port stunnel52 $stunnel52

### Restart Stunnel 5
cmd "systemctl stop stunnel5"
cmd "systemctl start stunnel5"
cmd "systemctl enable stunnel5"
