#!/bin/bash
# ==========================================
. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)

# hapus menu
rm -rf menu
rm -rf ipsaya
rm -rf sl-fix
rm -rf sshovpnmenu
rm -rf l2tpmenu
rm -rf pptpmenu
rm -rf sstpmenu
rm -rf wgmenu
rm -rf ssmenu
rm -rf ssrmenu
rm -rf vmessmenu
rm -rf vlessmenu
rm -rf grpcmenu
rm -rf grpcupdate
rm -rf trmenu
rm -rf trgomenu
rm -rf setmenu
rm -rf slowdnsmenu
rm -rf running
rm -rf copyrepo

# download menu
cd /usr/bin
rm -rf menu
rm -rf menuinfo
rm -rf restart
rm -rf slhost
rm -rf install-sldns
rm -rf addssh

loktemp=$(mktemp -d)
mkdir -p ${loktemp}
for abc in $(curl -Ls ${rawRepo}update/config); do
  # echo $abc
  tol=${rawRepo}${abc}
  echo $tol
  URL_NOPRO=${tol:7}
  URL_REL=${URL_NOPRO#*/}
  namaFile="/${URL_REL%%\?*}"
  # echo $namaFile
  wget -O "${loktemp}/${namaFile}" ${tol} &>/dev/null
done

# chmod +x $loktemp/*
# mv $loktemp/* /usr/bin/

# sl-download-info
# #install-sldns
# #install-ss-plugin
# #xray-grpc
# cd $home
