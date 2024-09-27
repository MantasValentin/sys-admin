#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <SERVER_IP> <CLIENT_NAME>"
    echo "Example: bash OpenVPN_client_conf.sh 192.168.0.110 client1"
    exit 1
fi

# Assign command line arguments to variables
SERVER_IP=$1
CLIENT_NAME=$2

# Change to the Easy-RSA directory
cd /etc/openvpn/server/easy-rsa

# Generate client certificate and key without a password
sudo ./easyrsa build-client-full $CLIENT_NAME nopass

# Read the content of necessary files
CA_CRT=$(cat /etc/openvpn/server/ca.crt)
TA_KEY=$(cat /etc/openvpn/server/ta.key)
CLIENT_CRT=$(cat /etc/openvpn/server/easy-rsa/pki/issued/$CLIENT_NAME.crt)
CLIENT_KEY=$(cat /etc/openvpn/server/easy-rsa/pki/private/$CLIENT_NAME.key)

# Create the client configuration file
sudo tee /etc/openvpn/client/$CLIENT_NAME.ovpn > /dev/null <<EOT
client
dev tun
proto tcp
remote $SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
verb 3
<ca>
$CA_CRT
</ca>
<cert>
$CLIENT_CRT
</cert>
<key>
$CLIENT_KEY
</key>
<tls-auth>
$TA_KEY
</tls-auth>
key-direction 1
EOT