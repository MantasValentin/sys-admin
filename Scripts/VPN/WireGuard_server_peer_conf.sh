#!/bin/bash

# Check if both arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <CLIENT_PUB_KEY_FILE> <CLIENT_VPN_IP>"
    exit 1
fi

# Add a peer to the WireGuard server
CLIENT_PUB_KEY=$(cat "$1")
CLIENT_VPN_IP=$2
sudo tee -a /etc/wireguard/wg0.conf > /dev/null <<EOT
[Peer]
PublicKey = ${CLIENT_PUB_KEY}
AllowedIPs = ${CLIENT_VPN_IP}

EOT

# Restart the service
sudo systemctl restart wg-quick@wg0