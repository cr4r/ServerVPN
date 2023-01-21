#!/bin/bash

msg -line " Menginstall badvpn "
msg -org "Mengunduh dan membuat permission badvpn-udpgw"
wget -O /usr/bin/badvpn-udpgw "${pssh}/badvpn-udpgw"
chmod +x /usr/bin/badvpn-udpgw

maxClientBadVPN=999
msg -warn "Menjalankan badvpn dengan port $badvpn1,$badvpn2,$badvpn3 dengan max client ${maxClientBadVPN}"

sed -i "$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$badvpn1 --max-clients $maxClientBadVPN" /etc/rc.local &>/dev/null
sed -i "$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$badvpn2 --max-clients $maxClientBadVPN" /etc/rc.local &>/dev/null
sed -i "$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$badvpn3 --max-clients $maxClientBadVPN" /etc/rc.local &>/dev/null

screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$badvpn1 --max-clients $maxClientBadVPN &>/dev/null
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$badvpn2 --max-clients $maxClientBadVPN &>/dev/null
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$badvpn3 --max-clients $maxClientBadVPN &>/dev/null

msg -red "Seting ufw port $badvpn1,$badvpn2,$badvpn3 untuk udpgw"
ufw allow $badvpn1 &>/dev/null
ufw allow $badvpn2 &>/dev/null
ufw allow $badvpn3 &>/dev/null

### Catat Port di /etc/port
c_port $file_port badvpn1 $badvpn1
c_port $file_port badvpn2 $badvpn2
c_port $file_port badvpn3 $badvpn3
