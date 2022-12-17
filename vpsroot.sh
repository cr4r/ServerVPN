#!/bin/bash

. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)

wget -qO- -O /etc/ssh/sshd_config https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/sshd_config
systemctl restart sshd
clear

while [[ $pwe == "" ]]; do
  msg -org "Masukkan Password Baru: " && read pwe
  tput cuu1 && tput dl1
done

while [[ $encrp != @(s|S|y|Y|n|N|t|T) ]]; do
  msg -org "Password ingin di encrypt?: " && read encrp
  tput cuu1 && tput dl1
done

if [[ $encrp == @(s|S|y|Y) ]]; then
  pwe=$(perl -e "print crypt("$pwe","Q4")")
fi

usermod -p ${pwe} root

clear
msg -org "Mohon Simpan Informasi Akun VPS Ini"
printf "============================================
Akun Root (Akun Utama)
Ip address = $(curl -Ls http://ipinfo.io/ip)
Username   = root
Password   = ${pwe}
============================================"
echo ""
pause
