#!/bin/bash
# ==========================================
. <(curl -s https://raw.githubusercontent.com/cr4r/ServerVPN/main/config)

# hapus menu
rm -rf $(whereis menu) &>/dev/null
rm -rf $(whereis ipsaya) &>/dev/null
rm -rf $(whereis sl-fix) &>/dev/null
rm -rf $(whereis sshovpnmenu) &>/dev/null
rm -rf $(whereis l2tpmenu) &>/dev/null
rm -rf $(whereis pptpmenu) &>/dev/null
rm -rf $(whereis sstpmenu) &>/dev/null
rm -rf $(whereis wgmenu) &>/dev/null
rm -rf $(whereis ssmenu) &>/dev/null
rm -rf $(whereis ssrmenu) &>/dev/null
rm -rf $(whereis vmessmenu) &>/dev/null
rm -rf $(whereis vlessmenu) &>/dev/null
rm -rf $(whereis grpcmenu) &>/dev/null
rm -rf $(whereis grpcupdate) &>/dev/null
rm -rf $(whereis trmenu) &>/dev/null
rm -rf $(whereis trgomenu) &>/dev/null
rm -rf $(whereis setmenu) &>/dev/null
rm -rf $(whereis slowdnsmenu) &>/dev/null
rm -rf $(whereis running) &>/dev/null
rm -rf $(whereis copyrepo) &>/dev/null
rm -rf $(whereis menu) &>/dev/null
rm -rf $(whereis menuinfo) &>/dev/null
rm -rf $(whereis restart) &>/dev/null
rm -rf $(whereis slhost) &>/dev/null
rm -rf $(whereis install-sldns) &>/dev/null
rm -rf $(whereis addssh) &>/dev/null

loktemp=$(mktemp -d)
mkdir -p ${loktemp}
for abc in $(curl -Ls ${rawRepo}update/plugin); do
  tol=${rawRepo}${abc}
  namaFile="${tol##*/}"
  lokasi="/usr/bin/${namaFile}"
  msg -org "Mengambil ${tol} ke ${lokasi}"
  wget -O ${lokasi} ${tol} &>/dev/null
  chmod +x $lokasi
done

# sl-download-info
# # install-sldns
# # install-ss-plugin
# # xray-grpc
cd $home
