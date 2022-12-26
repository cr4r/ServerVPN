#!/bin/bash
# SL
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
# ==========================================
# Getting
. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)

Add_To_New_Line() {
	if [ "$(tail -n1 $1 | wc -l)" == "0" ]; then
		echo "" >>"$1"
	fi
	echo "$2" >>"$1"
}

Check_And_Add_Line() {
	if [ -z "$(cat "$1" | grep "$2")" ]; then
		Add_To_New_Line "$1" "$2"
	fi
}

Install_BBR() {
	msg -line
	msg -gr "Install TCP_BBR..."
	if [ -n "$(lsmod | grep bbr)" ]; then
		msg -gr "TCP_BBR sudah diinstall."
		msg -line
		return 1
	fi
	msg -org "Mulai menginstall TCP_BBR..."
	modprobe tcp_bbr &>/dev/null
	Add_To_New_Line "/etc/modules-load.d/modules.conf" "tcp_bbr"
	Add_To_New_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
	Add_To_New_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
	sysctl -p
	if [ -n "$(sysctl net.ipv4.tcp_available_congestion_control | grep bbr)" ] && [ -n "$(sysctl net.ipv4.tcp_congestion_control | grep bbr)" ] && [ -n "$(lsmod | grep "tcp_bbr")" ]; then
		msg -gr "TCP_BBR Install Success."
	else
		msg -warn "Gagal menginstall TCP_BBR."
	fi
	msg -line
}

Optimize_Parameters() {
	msg -line
	msg -red "Optimasi Parameters..."
	Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 51200"
	Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 51200"
	Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
	Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"
	Check_And_Add_Line "/etc/sysctl.conf" "fs.file-max = 51200"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.rmem_max = 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.wmem_max = 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.netdev_max_backlog = 250000"
	Check_And_Add_Line "/etc/sysctl.conf" "net.core.somaxconn = 4096"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_syncookies = 1"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_tw_reuse = 1"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fin_timeout = 30"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_keepalive_time = 1200"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_local_port_range = 10000 65000"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_syn_backlog = 8192"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_tw_buckets = 5000"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fastopen = 3"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mem = 25600 51200 102400"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_rmem = 4096 87380 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_wmem = 4096 65536 67108864"
	Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mtu_probing = 1"
	msg -gr "Optimasi Parameters Selesai."
	msg -line
}
Install_BBR
Optimize_Parameters
