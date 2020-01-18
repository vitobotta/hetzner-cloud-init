#!/bin/bash

TOKEN="$1"
WHITELIST_S="$2"

ufw allow proto tcp from any to any port 22,80,443

ufw -f enable

IFS=', ' read -r -a WHITELIST <<< "$WHITELIST_S"

for IP in "${WHITELIST[@]}"; do
  ufw allow from "$IP"
done

NODE_IPS=( $(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/servers' | jq -r '.servers[].public_net.ipv4.ip') )

for IP in "${NODE_IPS[@]}"; do
  ufw allow from "$IP"
done

ufw allow from 10.43.0.0/16
ufw allow from 10.42.0.0/16

ufw -f default deny incoming
ufw -f default allow outgoing
