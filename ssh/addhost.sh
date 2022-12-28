#!/bin/bash
clear

tanya "Domain/Host" domain

echo "IP=$domain" >>/var/lib/crot/ipvps.conf
echo $domain >/etc/xray/domain

certv2ray
