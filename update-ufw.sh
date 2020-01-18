#!/bin/bash

TOKEN="$1"
WHITELIST_S="$2"

NEW_NODE_IPS=( $(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/servers' | jq -r '.servers[].public_net.ipv4.ip') )

touch /etc/current_node_ips
cp /etc/current_node_ips /etc/old_node_ips
echo "" > /etc/current_node_ips

for IP in "${NEW_NODE_IPS[@]}"; do
  ufw allow from "$IP"
  echo "$IP" >> /etc/current_node_ips
done

IFS=$'\r\n' GLOBIGNORE='*' command eval 'OLD_NODE_IPS=($(cat /etc/old_node_ips))'

REMOVED=()
for i in "${OLD_NODE_IPS[@]}"; do
  skip=
  for j in "${NEW_NODE_IPS[@]}"; do
    [[ $i == $j ]] && { skip=1; break; }
  done
  [[ -n $skip ]] || REMOVED+=("$i")
done
declare -p REMOVED

for IP in "${REMOVED[@]}"; do
  ufw deny from "$IP"
done
