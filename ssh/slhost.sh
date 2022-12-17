#!/bin/bash
inst_comp jq &>/dev/null
inst_comp curl &>/dev/null

### Initial
rm -rf /root/domain &>/dev/null
rm -rf /etc/v2ray/domain &>/dev/null
rm -rf /etc/xray/domain &>/dev/null
rm -rf /etc/xray/domain &>/dev/null
rm -rf /root/nsdomain &>/dev/null
rm -rf /var/lib/crot/ipvps.conf &>/dev/null
rm -rf /root/nsdomain &>/dev/null
rm -rf /root/domain &>/dev/null

mkdir -p /usr/bin/xray
mkdir -p /usr/bin/v2ray
mkdir -p /etc/xray
mkdir -p /etc/v2ray

while [[ $konfirmDomain != @(s|S|y|Y|n|N|t|T) ]]; do
  msg -ne "Ada domain sendiri (Y/T) ? " && read konfirmDomain
  tput cuu1 && tput dl1
done

if [[ $konfirmDomain == @(s|S|y|Y) ]]; then
  msg -org "IP VPS Anda\t: $(msg -gr $IP)"
  while [[ $SUB_DOMAIN == "" ]]; do
    msg -ne "Domain yang diinginkan: " && read SUB_DOMAIN
    tput cuu1 && tput dl1
  done

  msg -line " Silahkan daftarkan ip server di manajer domain "
  msg -org "Content: ${IP}"
  msg -org "Type: $(msg -gr A)\t\t| Name : $SUB_DOMAIN"
  msg -org "TTL: $(msg -gr Auto)\t| Proxies: $(msg -gr None)"
  pause

  while [[ $NS_DOMAIN == "" ]]; do
    msg -ne "NS Domain yang diinginkan: " && read NS_DOMAIN
    tput cuu1 && tput dl1
  done
  msg -line " Silahkan buat NS Domain di manajer domain "
  msg -org "Type: $(msg -gr NS)"
  msg -org "NameServer : ns.$SUB_DOMAIN"
  msg -org "IP VPS Anda : $(msg -gr $IP)"
  pause
else
  ### Pembuatan Domain
  sub=$(tr </dev/urandom -dc a-z0-9 | head -c5)
  subsl=$(tr </dev/urandom -dc a-z0-9 | head -c5)
  DOMAIN=cr4r19.tech
  SUB_DOMAIN=vpn-${sub}.${DOMAIN}
  NS_DOMAIN=vpn-${sub}.${DOMAIN}

  CF_ID=cr4rrr@gmail.com
  CF_KEY=fb9fa140b428739981536a9f5db897f2b28e2

  ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

  RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

  if [[ "${#RECORD}" -le 10 ]]; then
    RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
      -H "X-Auth-Email: ${CF_ID}" \
      -H "X-Auth-Key: ${CF_KEY}" \
      -H "Content-Type: application/json" \
      --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
  fi

  RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')

  msg -org "Updating DNS NS for ${NS_DOMAIN}..."

  ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

  RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" | jq -r .result[0].id)

  if [[ "${#RECORD}" -le 10 ]]; then
    RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
      -H "X-Auth-Email: ${CF_ID}" \
      -H "X-Auth-Key: ${CF_KEY}" \
      -H "Content-Type: application/json" \
      --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}' | jq -r .result.id)
  fi

  RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}')
fi

clear
msg -gr "Domain VPS Anda : $SUB_DOMAIN"
msg -gr "Domain untuk SlowDNS : $NS_DOMAIN"
echo "IP=""$SUB_DOMAIN" >/var/lib/crot/ipvps.conf
echo $SUB_DOMAIN >/root/domain
echo "$SUB_DOMAIN" >/etc/v2ray/domain
echo "$NS_DOMAIN" >/root/nsdomain
echo "$SUB_DOMAIN" >/etc/xray/domain
pause
