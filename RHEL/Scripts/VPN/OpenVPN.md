dnf -y install epel-release
dnf -y install openvpn easy-rsa

# Generate the public/private key infrastructure:
sudo cp -r /usr/share/easy-rsa /etc/openvpn/server
cd /etc/openvpn/server/easy-rsa/3/
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
sudo vim /etc/openvpn/server/server.conf

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
group nogroup
persist-key
persist-tun

status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3

# Start the OpenVPN server service
sudo systemctl start openvpn@server

# Enable the OpenVPN server service to start on boot
sudo systemctl enable openvpn@server