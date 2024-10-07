#!/bin/bash

sudo dnf update

# Install OpenVPN and Easy-RSA
sudo dnf -y install epel-release
sudo dnf -y install openvpn easy-rsa

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
server 10.1.0.0 255.255.255.0
port 1194
proto tcp
dev tun
tls-server

key /etc/openvpn/server/server.key
cert /etc/openvpn/server/server.crt
dh /etc/openvpn/server/dh.pem
ca /etc/openvpn/server/ca.crt
tls-auth /etc/openvpn/server/ta.key 0

push "redirect-gateway def1 bypass-dhcp"
keepalive 10 120
user nobody
group nobody
persist-key
persist-tun

status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3
EOT

# Enable IP forwarding by uncommenting the line in sysctl.conf
sudo tee /etc/sysctl.conf > /dev/null <<EOT 
net.ipv4.ip_forward=1
EOT

# Apply the sysctl changes
sudo sysctl -p

# Set up firewall rules
sudo firewall-cmd --permanent --add-service=openvpn
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.1.0.0/24 -o ens33 -j MASQUERADE
sudo firewall-cmd --reload

# Start the OpenVPN server service
sudo systemctl start openvpn-server@server.service

# Enable the OpenVPN server service to start on boot
sudo systemctl enable openvpn-server@server.service