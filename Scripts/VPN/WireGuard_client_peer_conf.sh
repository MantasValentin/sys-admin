#!/bin/bash

# Check if both arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <SERVER_PUB_KEY_FILE> <SERVER_PUB_IP>"
    exit 1
fi

# Add a peer to the WireGuard client
SERVER_PUB_KEY=$(cat "$1")
SERVER_PUB_IP=$2
sudo tee -a /etc/wireguard/wg0-client.conf > /dev/null <<EOT
[Peer]
PublicKey = ${SERVER_PUB_KEY}
Endpoint = ${SERVER_IP}:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 30

EOT

# Restart the service
sudo wg-quick up /etc/wireguard/wg0-client.conf