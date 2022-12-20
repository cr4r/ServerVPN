#!/bin/bash
# ==========================================

sleep 20
systemctl stop ws-tls &>/dev/null
pkill python &>/dev/null
systemctl stop sslh &>/dev/null
systemctl daemon-reload &>/dev/null
systemctl disable ws-tls &>/dev/null
systemctl disable sslh &>/dev/null
systemctl daemon-reload &>/dev/null
systemctl enable sslh &>/dev/null
systemctl enable ws-tls &>/dev/null
systemctl start sslh &>/dev/null
/etc/init.d/sslh start &>/dev/null
/etc/init.d/sslh restart &>/dev/null
systemctl start ws-tls &>/dev/null
systemctl restart ws-tls
echo "Restart semua service"
restart
