#!/bin/bash

# Update package lists
sudo apt-get update

# Install OpenVPN and Easy-RSA
sudo apt install openvpn easy-rsa -y

# Create a directory for OpenVPN server configuration
sudo mkdir /etc/openvpn/server

# Copy Easy-RSA files to the OpenVPN server directory
sudo cp -r /usr/share/easy-rsa /etc/openvpn/server

# Change to the Easy-RSA directory
cd /etc/openvpn/server/easy-rsa

# Initialize the Public Key Infrastructure (PKI)
sudo ./easyrsa init-pki

# Build the Certificate Authority (CA) without a password
sudo ./easyrsa build-ca nopass

# Generate server certificate and key without a password
sudo ./easyrsa build-server-full server nopass

# Generate Diffie-Hellman parameters
sudo ./easyrsa gen-dh

# Generate a shared secret key for TLS authentication
sudo openvpn --genkey --secret /etc/openvpn/server/ta.key

# Copy necessary files (CA cert, server cert, server key, DH params) to OpenVPN server directory
sudo cp ./pki/ca.crt ./pki/issued/server.crt ./pki/private/server.key ./pki/dh.pem /etc/openvpn/server

# Create OpenVPN server configuration file
sudo tee /etc/openvpn/server.conf > /dev/null <<EOT
port 1194
proto udp
dev tun
tls-server
key /etc/openvpn/server/server.key
cert /etc/openvpn/server/server.crt
dh /etc/openvpn/server/dh.pem
ca /etc/openvpn/server/ca.crt
tls-auth /etc/openvpn/server/ta.key 0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log-append /var/log/openvpn.log
verb 3
EOT

# Enable IP forwarding by uncommenting the line in sysctl.conf
sudo sed -i "s/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf

# Apply the sysctl changes
sudo sysctl -p

# Start the OpenVPN server service
sudo systemctl start openvpn@server

# Enable the OpenVPN server service to start on boot
sudo systemctl enable openvpn@server