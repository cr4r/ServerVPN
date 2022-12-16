#!/bin/bash
. config
echo "$crot    ALL=(ALL:ALL) ALL" >>/etc/sudoers
wget -qO- -O /etc/ssh/sshd_config https://raw.githubusercontent.com/cr4r/ServerVPN/main/sshd_config
systemctl restart sshd
clear

while [[ ${pwe} = "" ]]; do
  msg -ne "Masukkan Password: " && read -e pwe
  tput cuu1 && tput dl1
done

pwe=$(perl -e "print crypt("$pwe","Q4")")
usermod -p $pwe root

msg -org "Mohon Simpan Informasi Akun VPS Ini"
printf "============================================
Akun Root (Akun Utama)
Ip address = $IP
Username   = root
Password   = $pwe
============================================
"
msg -ne "Tekan Enter" && read enter && tput cuu1 && tput dl1 && exit
