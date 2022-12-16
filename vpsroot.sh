#!/bin/bash
. config
# Mod By SL
#echo "$crot    ALL=(ALL:ALL) ALL" >> /etc/sudoers;
wget -qO- -O /etc/ssh/sshd_config https://raw.githubusercontent.com/cr4r/ServerVPN/main/sshd_config
systemctl restart sshd
clear

while [[ ${pwe} = "" ]]; do
  msg -org "Masukkan Password: " && read pwe
  tput cuu1 && tput dl1
done

usermod -p $(perl -e "print crypt("$pwe","Q4")") root
clear

printf "Mohon Simpan Informasi Akun VPS Ini
============================================
Akun Root (Akun Utama)
Ip address = $(IP)
Username   = root
Password   = $pwe
============================================"
read enter && exit
