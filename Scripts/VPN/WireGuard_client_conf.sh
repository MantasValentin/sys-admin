# This script sets up the WireGuard client

# Install WireGuard
sudo apt install wireguard

# Generate private and public keys
wg genkey | tee privatekey | wg pubkey | tee publickey

# Create a WireGuard configuration file
PRIVATE_KEY=$(cat privatekey) # Change this
Client_VPN_IP=10.0.0.2/32 # Change this

sudo tee /etc/wireguard/wg0-client.conf > /dev/null <<EOT
[Interface]
PrivateKey = ${PRIVATE_KEY}
Address = ${Client_VPN_IP}
EOT