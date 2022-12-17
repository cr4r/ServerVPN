#!/bin/bash
# Mod By SL
# =====================================================

# Color
NC='\033[0m'

MYIP=$(wget -qO- ipinfo.io/ip)
domain=$(cat /etc/xray/domain)

inst_comp $(curl -Ls https://raw.githubusercontent.com/cr4r/ServerVPN/main/xray/plugin)

msg -org "Update jam pada server"
ntpdate pool.ntp.org &>/dev/null
timedatectl set-ntp true &>/dev/null
msg -org "systemctl enable chronyd && systemctl restart chronyd"
systemctl enable chronyd &>/dev/null && systemctl restart chronyd &>/dev/null
msg -org "systemctl enable chrony && systemctl restart chrony"
systemctl enable chrony &>/dev/null && systemctl restart chrony &>/dev/null
msg -org "timedatectl set-timezone Asia/Jakarta"
timedatectl set-timezone Asia/Jakarta &>/dev/null
msg -line "chronyc sourcestats"
chronyc sourcestats -v &>/dev/null
msg -line "chronyc tracking "
chronyc tracking -v
msg -org "$(date)"

### Ambil Xray Core Version Terbaru
### Installation Xray Core
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
xraycore_link="https://github.com/XTLS/Xray-core/releases/download/v$latest_version/xray-linux-64.zip"

### Make Main Directory
msg -org "Buat Folder /usr/bin/xray"
msg -org "Buat Folder /etc/xray"
mkdir -p /usr/bin/xray /etc/xray

# / / Unzip Xray Linux 64
loktmp=$(mktemp -d)
msg -org "${loktmp}"
msg -org "Ke lokasi $loktmp"
curl -sL "$xraycore_link" -o xray.zip
msg -org "GET $xraycore_link ke $loktmp"
unzip -oq xray.zip && rm -rf xray.zip
msg -org "UNZIP $loktmp/xray.zip dan Hapus xray.zip"
mv xray /usr/local/bin/xray
msg -org "mv xray /usr/local/bin/xray"
chmod +x /usr/local/bin/xray
msg -org "chmod +x /usr/local/bin/xray"

# # Make Folder XRay
msg -org "mkdir -p /var/log/xray/"
mkdir -p /var/log/xray/

msg -org "kill_port 80"
kill_port 80 &>/dev/null

if [[ -f /etc/nginx/sites-enable/default ]]; then
  msg -warn "Menghapus default nginx"
  rm /etc/nginx/sites-enabled/default &>/dev/null
  msg -warn "Merestart nginx"
  systemctl restart nginx &>/dev/null
fi

cd $home
msg -gr "Cert digunakan untuk mendukung https dan ini wajib!!"
while [[ $konCert != @(s|S|y|Y|n|N|t|T) ]]; do
  msg -org "Apakah sudah ada cert untuk domain ? (Y/T)" && read konCert
  tput cuu1 && tput dl1
done
echo $konCert
if [[ $konCert == @(s|S|y|Y) ]]; then
  while [[ $path_crt == "" ]]; do
    msg -ne "Lokasi FullChain: " && read path_crt
    tput cuu1 && tput dl1
  done
  while [[ $path_key == "" ]]; do
    msg -ne "Lokasi FullChain: " && read path_key
    tput cuu1 && tput dl1
  done
else
  mkdir -p /var/www
  msg -red "Membuat config nginx untuk port 80"
  cat <<EOF >/etc/nginx/sites-available/port80.conf
server {
  listen 80;
  server_name $domain;
  location / {
      root /var/www;
  }
}
EOF
  ln -s /etc/nginx/sites-available/port80.conf /etc/nginx/sites-enabled/port80.conf
  nginx -t &>/dev/null
  msg -warn "Merestart Nginx"
  systemctl restart nginx &>/dev/null

  msg -warn "Generate crt dan key di certbot"
  sudo certbot --non-interactive --redirect --nginx -d $domain --agree-tos -m admin@$domain
  path_crt="/etc/letsencrypt/live/$domain/fullchain.pem"
  path_key="/etc/letsencrypt/live/$domain/privkey.pem"
  rm /etc/nginx/sites-enabled/port80.conf &>/dev/null
  systemctl restart nginx &>/dev/null

  ### Versi ACME
  # wget https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh &>/dev/null
  # msg -line "Membuat cert dari script acme.sh"
  # bash acme.sh --install && rm acme.sh
  # ln -s ~/.acme.sh/acme.sh /bin/acme

  # acme --register-account -m cr4rrr@gmail.com
  # acme --issue --standalone -d $domain --force
  # acme --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key
  # cd $home
  # path_crt="/etc/xray/xray.crt"
  # path_key="/etc/xray/xray.key"
fi
service squid start &>/dev/null
uuid7=$(cat /proc/sys/kernel/random/uuid)
uuid1=$(cat /proc/sys/kernel/random/uuid)
uuid2=$(cat /proc/sys/kernel/random/uuid)
uuid3=$(cat /proc/sys/kernel/random/uuid)
uuid4=$(cat /proc/sys/kernel/random/uuid)
uuid5=$(cat /proc/sys/kernel/random/uuid)
uuid6=$(cat /proc/sys/kernel/random/uuid)

### Buat Config Xray
msg -line "Buat Config Xray"
pathV2ray="/worryfree/"
pathVless=$pathV2ray
cat >/etc/xray/config.json <<END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 8443,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid1}",
            "alterId": 0
#xray-vmess-tls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ]
        },
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "${pathV2ray}",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      }
    },
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [

          {
            "id": "${uuid2}",
            "alterId": 0
#xray-vmess-nontls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "tlsSettings": {},
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "${pathV2ray}",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid3}"
#xray-vless-tls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ]
        },
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "/vless/",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "domain": "$domain",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 80,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid4}"
#xray-vless-nontls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "tlsSettings": {},
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "${pathVless}",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 2083,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid5}"
#xray-trojan
          }
        ],
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ],
          "alpn": [
            "http/1.1"
          ]
        },
        "tcpSettings": {},
        "kcpSettings": {},
        "wsSettings": {},
        "httpSettings": {},
        "quicSettings": {},
        "grpcSettings": {}
      },
      "domain": "$domain"
     }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
END

### Installation Xray Service
msg -warn "Installation Xray Service"
msg -org "Buat File >/etc/systemd/system/xray.service"

cat <<EOF >/etc/systemd/system/xray.service
[Unit]
Description=Xray Service Mod By SL
Documentation=https://github.com/cr4r
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

### Menambahkan port pada ufw untuk xray
# # Accept port Xray
msg -warn "Menambahkan port pada ufw untuk xray!"
ufw allow 8443/tcp
ufw allow 8443/udp
ufw allow 80/udp
ufw allow 80/tcp &>/dev/null
ufw allow 2083/udp
ufw allow 2083/tcp

msg -warn "Memulai service xray"
systemctl daemon-reload
systemctl stop xray.service
systemctl enable xray.service
systemctl start xray.service
systemctl restart xray.service

### Install Trojan Go
msg -line "Install Trojan Go"
latest_version="$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases" | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
trojango_link="https://github.com/p4gefau1t/trojan-go/releases/download/v${latest_version}/trojan-go-linux-amd64.zip"
msg -org "Membuat folder /usr/bin/trojan-go"
mkdir -p "/usr/bin/trojan-go"
msg -org "Membuat folder /etc/trojan-go"
mkdir -p "/etc/trojan-go"

loktemp=$(mktemp -d)
msg -org "Menuju ke $loktemp"
cd $(mktemp -d)
msg -org "curl -sL "${trojango_link}" -o trojan-go.zip"
curl -sL "${trojango_link}" -o trojan-go.zip
msg -org "unzip -qo trojan-go.zip && rm -rf trojan-go.zip"
unzip -qo trojan-go.zip && rm -rf trojan-go.zip
msg -org "mv trojan-go /usr/local/bin/trojan-go"
mv trojan-go /usr/local/bin/trojan-go
msg -org "chmod +x /usr/local/bin/trojan-go"
chmod +x /usr/local/bin/trojan-go
msg -org "mkdir /var/log/trojan-go/"
mkdir /var/log/trojan-go/
msg -org "touch /etc/trojan-go/akun.conf /var/log/trojan-go/trojan-go.log"
touch /etc/trojan-go/akun.conf /var/log/trojan-go/trojan-go.log

msg -org "Membuat Config Trojan GO"
# # Buat Config Trojan Go
cat >/etc/trojan-go/config.json <<END
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2087,
  "remote_addr": "127.0.0.1",
  "remote_port": 89,
  "log_level": 1,
  "log_file": "/var/log/trojan-go/trojan-go.log",
  "password": [
      "$uuid"
  ],
  "disable_http_check": true,
  "udp_timeout": 60,
  "ssl": {
    "verify": false,
    "verify_hostname": false,
    "cert": "/etc/xray/xray.crt",
    "key": "/etc/xray/xray.key",
    "key_password": "",
    "cipher": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "$domain",
    "alpn": [
      "http/1.1"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_addr": "127.0.0.1",
    "fallback_port": 0,
    "fingerprint": "firefox"
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "prefer_ipv4": true
  },
  "mux": {
    "enabled": false,
    "concurrency": 8,
    "idle_timeout": 60
  },
  "websocket": {
    "enabled": true,
    "path": "/trojango",
    "host": "$domain"
  },
    "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0,
    "ssl": {
      "enabled": false,
      "key": "",
      "cert": "",
      "verify_client": false,
      "client_cert": []
    }
  }
}
END

msg -org "Installing Trojan Go Service"
### Installing Trojan Go Service
cat >/etc/systemd/system/trojan-go.service <<END
[Unit]
Description=Trojan-Go Service Mod By cr4r
Documentation=nekopoi.care
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
END

# Trojan Go Uuid
cat >/etc/trojan-go/uuid.txt <<END
$uuid
END

### restart
msg -org "ufw allow port 2086/tcp"
ufw allow 2086/tcp
msg -org "ufw allow port 2087/udp"
ufw allow 2087/udp
msg -warn "Restart Service trojan GO"
systemctl daemon-reload
systemctl stop trojan-go
systemctl start trojan-go
systemctl enable trojan-go
systemctl restart trojan-go

cd $home
cp /root/domain /etc/xray
