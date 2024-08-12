#!/bin/bash

# This script sets up the WireGuard server

# Install WireGuard
sudo apt install wireguard

# Generate private and public keys
wg genkey | tee privatekey | wg pubkey | tee publickey

# Allow ipv4 forwarding
sudo sed -i "s/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sudo sysctl -p

# Create a WireGuard configuration file
PRIVATE_KEY=$(cat privatekey) # Change this
NETWORK_INTERFACE=enp0s3 # Change this
SERVER_VPN_IP=10.0.0.1/24 # Change this

sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOT
[Interface]
PrivateKey = ${PRIVATE_KEY}
Address = ${SERVER_VPN_IP}
ListenPort = 51820
EOT

# Configure firewall
sudo nft add table inet filter
sudo nft add chain inet filter input { type filter hook input priority 0 \; policy accept \; }
sudo nft add rule inet filter input iif "wg0" accept
sudo nft add chain inet filter forward { type filter hook forward priority 0 \; policy accept \; }
sudo nft add rule inet filter forward iif "wg0" accept
sudo nft add rule inet filter forward oif "wg0" accept
sudo nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }
sudo nft add table ip nat
sudo nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
sudo nft add rule ip nat postrouting ip saddr 10.0.0.0/24 oif $NETWORK_INTERFACE masquerade

# Save the firewall configuration
sudo nft list ruleset > /etc/nftables.conf

# Start WireGuard service
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0