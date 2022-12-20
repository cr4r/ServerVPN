#!/bin/bash
# ==========================================

msg() {
  local colors="/etc/new-cr4r-color"
  if [[ ! -e $colors ]]; then
    COLOR[0]='\033[1;37m' #BRAN='\033[1;37m'
    COLOR[1]='\e[31m'     #VERMELHO='\e[31m'
    COLOR[2]='\e[32m'     #VERDE='\e[32m'
    COLOR[3]='\e[33m'     #AMARELO='\e[33m'
    COLOR[4]='\e[34m'     #AZUL='\e[34m'
    COLOR[5]='\e[35m'     #MAGENTA='\e[35m'
    COLOR[6]='\033[1;36m' #MAG='\033[1;36m'
  else
    local COL=0
    for number in $(cat $colors); do
      case $number in
      1) COLOR[$COL]='\033[1;37m' ;;
      2) COLOR[$COL]='\e[31m' ;;
      3) COLOR[$COL]='\e[32m' ;;
      4) COLOR[$COL]='\e[33m' ;;
      5) COLOR[$COL]='\e[34m' ;;
      6) COLOR[$COL]='\e[35m' ;;
      7) COLOR[$COL]='\033[1;36m' ;;
      esac
      let COL++
    done
  fi
  NEGRITO='\e[1m'
  SEMCOR='\e[0m'
  cor="${COLOR[4]}————————————————————"
  garis=${SEMCOR}${cor}${SEMCOR}
  case $1 in
  -ne) cor="${COLOR[1]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -org) cor="${COLOR[3]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -warn) cor="${COLOR[3]}${NEGRITO}[!] ${COLOR[1]}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -red) cor="${COLOR[1]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -gr) cor="${COLOR[6]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -bra) cor="${COLOR[0]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -line) echo -e "${garis}${2}${garis}" ;;
  esac
}
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
for abc in $(curl -s ${rawRepo}/update/config); do
  tol=${rawRepo}${abc}
  wget -O $loktemp $tol
done

chmod +x $loktemp/*
mv $loktemp/* /usr/bin/

sl-download-info
#install-sldns
#install-ss-plugin
#xray-grpc
cd $home
