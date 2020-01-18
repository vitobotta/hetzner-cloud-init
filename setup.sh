#!/bin/bash

TOKEN="$1"
WHITELIST_S="$2"

curl -o /usr/local/sbin/apt-get https://raw.githubusercontent.com/vitobotta/hetzner-cloud-init/master/apt-get

chmod +x /usr/local/sbin/apt-get

apt-get install -y jq ufw fail2ban

curl -o /usr/local/bin/update-ufw.sh https://raw.githubusercontent.com/vitobotta/hetzner-cloud-init/master/update-ufw.sh

chmod +x /usr/local/bin/update-ufw.sh

/usr/local/bin/update-ufw.sh ${TOKEN} ${WHITELIST_S}

cat <<EOF >> /etc/crontab
* * * * * root /usr/local/bin/update-ufw.sh ${TOKEN} ${WHITELIST_S}
EOF
