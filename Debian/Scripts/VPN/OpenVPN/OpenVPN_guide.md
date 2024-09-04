# Update the package lists:
sudo apt-get update

# Install OpenVPN and easy-rsa:
sudo apt install openvpn easy-rsa -y

# Create the OpenVPN server directory:
sudo mkdir /etc/openvpn/server

# Generate the public/private key infrastructure:
sudo cp -r /usr/share/easy-rsa /etc/openvpn/server
cd /etc/openvpn/server/easy-rsa 
sudo ./easyrsa init-pki

# Build the certificate authority (CA):
sudo ./easyrsa build-ca nopass

# Generate the server certificate and key:
sudo ./easyrsa build-server-full server nopass

# Generate Diffie-Hellman parameters:
sudo ./easyrsa gen-dh

# Copy the required files to the OpenVPN server directory:
sudo cp pki/ca.crt pki/issued/server.crt pki/private/server.key pki/dh.pem /etc/openvpn/server

# Generate TLS auth key
sudo openvpn --genkey --secret /etc/openvpn/server/ta.key

# Create the OpenVPN server configuration file:
sudo nano /etc/openvpn/server/server.conf

port 1194
proto udp
dev tun
tls-server
key server.key
cert server.crt
dh dh.pem
ca ca.crt
tls-auth ta.key 0
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

# Enable IP forwarding:
sudo sysctl -w net.ipv4.ip_forward=1

# Start the OpenVPN server:
sudo systemctl start openvpn@server

# Enable the OpenVPN server to start automatically on system boot:
sudo systemctl enable openvpn@server


# Generate client certificates:
cd /etc/openvpn/server/easy-rsa
sudo ./easyrsa build-client-full client1 nopass


# Create the client configuration file: on local machine
vim client1.ovpn

client
dev tun
proto udp
remote YOUR_SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
verb 3

# Copy the necessary files from the server:
/etc/openvpn/server/ca.crt
/etc/openvpn/server/ta.key
/etc/openvpn/server/easy-rsa/pki/issued/client1.crt
/etc/openvpn/server/easy-rsa/pki/private/client1.key

# Embed the certificates and keys in the client config: Add the following to your client1.ovpn file, replacing the placeholders with the actual content of each file:
<ca>
(Contents of ca.crt)
</ca>

<cert>
(Contents of client1.crt)
</cert>

<key>
(Contents of client1.key)
</key>

<tls-auth>
(Contents of ta.key)
</tls-auth>
key-direction 1

# Move files
cp ./client1.ovpn /etc/openvpn/client/

# Start the vpn connection
sudo openvpn --config /etc/openvpn/client/client1.ovpn --route-gateway 192.168.0.130











# Generate a new key for the intermediate CA:
sudo ./easyrsa gen-req intermediate-ca nopass

# Sign the intermediate CA certificate with your root CA:
sudo ./easyrsa sign-req ca intermediate-ca

# Generate a key and certificate signing request for the server
sudo ./easyrsa gen-req server nopass

# Sign the server certificate using the intermediate CA
sudo ./easyrsa sign-req server server

# Generate Diffie-Hellman parameters
sudo ./easyrsa gen-dh

# Generate TLS-Auth key
sudo openvpn --genkey secret ta.key

# Generate a key and certificate signing request for a client
sudo ./easyrsa gen-req client1 nopass

# Sign the client certificate using the intermediate CA
sudo ./easyrsa sign-req client client1




sudo ./easyrsa build-client-full CLIENT_NAME nopass

sudo ./easyrsa build-server-full SERVER_NAME nopass