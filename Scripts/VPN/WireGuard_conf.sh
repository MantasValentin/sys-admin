#!/bin/bash

# This script is for installing, configuring, and adding peers to the VPN server, in addition creating the client WireGuard config file for connecting to the VPN server

# Check if both arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <SERVER_IP> <NETWORK_INTERFACE>"
    echo "Example: bash WireGuard_conf.sh 192.168.0.110 enp0s3"
    exit 1
fi

# Generate random numbers for the client's VPN IP (10.0.0.0/8 range)
OCTET2=$(( (RANDOM % 254) + 1 )) # Ensure range is 1-254
OCTET3=$(( (RANDOM % 254) + 1 )) # Ensure range is 1-254
OCTET4=$(( (RANDOM % 253) + 2 )) # Ensure range is 2-254

SERVER_IP=$1
NETWORK_INTERFACE=$2
CLIENT_VPN_IP="10.$OCTET2.$OCTET3.$OCTET4/32"
SERVER_VPN_IP="10.0.0.1/8" # Change this as necessary

# Check if the WireGuard config file exists and create one if it doesn't
if [ ! -e "/etc/wireguard/wg0.conf" ]; then
    echo "Creating WireGuard server configuration..."
    # Generate server private and public keys
    SERVER_PRIVATE_KEY=$(wg genkey)

    # Create the VPN config file
    sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOT
[Interface]
PrivateKey = ${SERVER_PRIVATE_KEY}
Address = ${SERVER_VPN_IP}
ListenPort = 51820
EOT

    # Start the service
    sudo systemctl enable wg-quick@wg0
    sudo systemctl start wg-quick@wg0

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
    sudo nft add rule ip nat postrouting ip saddr 10.0.0.0/8 oif $NETWORK_INTERFACE masquerade

    # Save the firewall configuration
    sudo nft list ruleset > /etc/nftables.conf
else
    echo "/etc/wireguard/wg0.conf already exists. Skipping server configuration..."
fi

# Generate client private and public keys
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

# Add a peer to the WireGuard server
sudo tee -a /etc/wireguard/wg0.conf > /dev/null <<EOT
[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_VPN_IP}
EOT

# Restart the service
sudo systemctl restart wg-quick@wg0

# Create the client WireGuard configuration file
# Read existing server private key
SERVER_PRIVATE_KEY=$(grep "PrivateKey" /etc/wireguard/wg0.conf | awk '{print $3}')
SERVER_PUBLIC_KEY=$(echo "$SERVER_PRIVATE_KEY" | wg pubkey)

sudo tee wg0-client.conf > /dev/null <<EOT
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_VPN_IP}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_IP}:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOT

echo "Client configuration file created: wg0-client.conf"