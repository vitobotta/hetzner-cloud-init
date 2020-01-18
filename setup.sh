#!/bin/bash

TOKEN="$1"
WHITELIST_S="$2"

sed -i 's/[#]*PermitRootLogin yes/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/[#]*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

systemctl restart sshd

curl -o /usr/local/sbin/apt-get https://raw.githubusercontent.com/vitobotta/hetzner-cloud-init/master/apt-get

chmod +x /usr/local/sbin/apt-get

apt-get install -y jq ufw fail2ban

curl -o /usr/local/bin/update-ufw.sh https://raw.githubusercontent.com/vitobotta/hetzner-cloud-init/master/update-ufw.sh

chmod +x /usr/local/bin/update-ufw.sh

ufw allow proto tcp from any to any port 22,80,443

ufw -f enable

IFS=', ' read -r -a WHITELIST <<< "$WHITELIST_S"

for IP in "${WHITELIST[@]}"; do
  ufw allow from "$IP"
done

ufw allow from 10.43.0.0/16
ufw allow from 10.42.0.0/16

ufw -f default deny incoming
ufw -f default allow outgoing

/usr/local/bin/update-ufw.sh ${TOKEN} ${WHITELIST_S}

cat <<EOF >> /etc/crontab
* * * * * root /usr/local/bin/update-ufw.sh ${TOKEN} ${WHITELIST_S}
EOF
