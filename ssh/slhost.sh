#!/bin/bash
inst_comp jq curl -y &>/dev/null

### Initial
rm -f /root/domain &>/dev/null
rm -f /etc/v2ray/domain &>/dev/null
rm -f /etc/xray/domain &>/dev/null
rm -rf /etc/xray/domain &>/dev/null
rm -rf /root/nsdomain &>/dev/null
rm -rf /var/lib/crot/ipvps.conf &>/dev/null
rm -rf /root/nsdomain &>/dev/null
rm -rf /root/domain &>/dev/null

mkdir -p /usr/bin/xray
mkdir -p /usr/bin/v2ray
mkdir -p /etc/xray
mkdir -p /etc/v2ray
echo "$SUB_DOMAIN" >>/etc/v2ray/domain

#
sub=$(tr </dev/urandom -dc a-z0-9 | head -c5)
subsl=$(tr </dev/urandom -dc a-z0-9 | head -c5)
DOMAIN=cr4r19.tech
SUB_DOMAIN=sub-${sub}.${DOMAIN}
NS_DOMAIN=ns-${sub}.${DOMAIN}
CF_ID=ahmadfatchurrachman@gmail.com
CF_KEY=ZK7QtaaJjvufdsF6mwSu-uzzEAckFytEGR7iYM7R
echo $NS_DOMAIN
# set -euo pipefail
# ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
#      -H "X-Auth-Email: ${CF_ID}" \
#      -H "X-Auth-Key: ${CF_KEY}" \
#      -H "Content-Type: application/json" | jq -r .result[0].id)

# RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
#      -H "X-Auth-Email: ${CF_ID}" \
#      -H "X-Auth-Key: ${CF_KEY}" \
#      -H "Content-Type: application/json" | jq -r .result[0].id)

# if [[ "${#RECORD}" -le 10 ]]; then
#      RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
#           -H "X-Auth-Email: ${CF_ID}" \
#           -H "X-Auth-Key: ${CF_KEY}" \
#           -H "Content-Type: application/json" \
#           --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
# fi

# RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
#      -H "X-Auth-Email: ${CF_ID}" \
#      -H "X-Auth-Key: ${CF_KEY}" \
#      -H "Content-Type: application/json" \
#      --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')

# echo "Updating DNS NS for ${NS_DOMAIN}..."
# ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
#      -H "X-Auth-Email: ${CF_ID}" \
#      -H "X-Auth-Key: ${CF_KEY}" \
#      -H "Content-Type: application/json" | jq -r .result[0].id)

# RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
#      -H "X-Auth-Email: ${CF_ID}" \
#      -H "X-Auth-Key: ${CF_KEY}" \
#      -H "Content-Type: application/json" | jq -r .result[0].id)

# if [[ "${#RECORD}" -le 10 ]]; then
#      RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
#           -H "X-Auth-Email: ${CF_ID}" \
#           -H "X-Auth-Key: ${CF_KEY}" \
#           -H "Content-Type: application/json" \
#           --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}' | jq -r .result.id)
# fi

# RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
#      -H "X-Auth-Email: ${CF_ID}" \
#      -H "X-Auth-Key: ${CF_KEY}" \
#      -H "Content-Type: application/json" \
#      --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}')

# echo "IP=""$SUB_DOMAIN" >>/var/lib/crot/ipvps.conf
# echo "Host : $SUB_DOMAIN"
# echo $SUB_DOMAIN >/root/domain
# echo "Host SlowDNS : $NS_DOMAIN"
# echo "$NS_DOMAIN" >/root/nsdomain
# echo "$SUB_DOMAIN" >/etc/xray/domain
# cd
