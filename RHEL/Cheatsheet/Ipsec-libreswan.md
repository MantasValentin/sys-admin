# Install libreswan
dnf install libreswan

# if re-installing libreswan remove the old database and create a new one
systemctl stop ipsec
rm /var/lib/ipsec/nss/*db
ipsec initnss

# Start ipsec
systemctl enable ipsec --now

# Configure firewall to allow ipsec traffic or 500/UDP and 4500/UDP ports
firewall-cmd --add-service="ipsec"
firewall-cmd --add-port=500/udp
firewall-cmd --add-port=4500/udp
firewall-cmd --runtime-to-permanent

# Generate a RSA key pair on each host
ipsec newhostkey

# List keys and use ckaid to show the key
ipsec showhostkey --list
ipsec showhostkey --left --ckaid <ckaid>
ipsec showhostkey --right --ckaid <ckaid>

# Configure one way VPN traffic from server 1 to server 2
vim /etc/ipsec.d/test.conf

# Server 1
config setup
    logfile=/var/log/pluto.log
    logappend=no
    plutodebug=all

conn %default
    ikelifetime=1h
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    dpddelay=30
    dpdtimeout=120
    dpdaction=restart

conn mytunnel
    leftid=192.168.0.222
    left=192.168.0.222
    leftsubnet=0.0.0.0/0
    leftrsasigkey=0sAwEAAb... # (your full key here)
    rightid=192.168.0.223
    right=192.168.0.223
    rightrsasigkey=0sAwEAAc... # (your full key here)
    auto=start
    authby=rsasig
    ike=aes256-sha2;modp2048
    esp=aes256-sha2
    ikev2=yes

# Server 2
config setup
    logfile=/var/log/pluto.log
    logappend=no
    plutodebug=all

conn %default
    ikelifetime=1h
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    dpddelay=30
    dpdtimeout=120
    dpdaction=restart

conn mytunnel
    leftid=192.168.0.223
    left=192.168.0.223
    leftrsasigkey=0sAwEAAc... # (your full key here)
    rightid=192.168.0.222
    right=192.168.0.222
    rightsubnet=0.0.0.0/0
    rightrsasigkey=0sAwEAAb... # (your full key here)
    auto=start
    authby=rsasig
    ike=aes256-sha2;modp2048
    esp=aes256-sha2
    ikev2=yes

# Restart the service
systemctl restart ipsec

# Configure full tunnel VPN traffic
vim /etc/ipsec.d/server.conf

# VPN Server
# /etc/ipsec.d/server.conf

config setup
    plutodebug=all
    dumpdir=/var/run/pluto/
    nssdir=/etc/ipsec.d

conn %default
    ikev2=insist  # Force IKEv2 only
    ike=aes256-sha256-modp2048  # Encryption algorithm for phase 1 (IKE)
    esp=aes256-sha256  # Encryption algorithm for phase 2 (ESP)
    dpdaction=clear  # Dead Peer Detection, clear if the client is unreachable
    dpddelay=30  # Dead Peer Detection interval
    dpdtimeout=120  # Time before considering the peer dead
    authby=rsasig  # Use RSA signature (certificate-based authentication)

conn full-tunnel
    left=%defaultroute  # Server's public IP
    leftid=@vpnserver  # Server's identifier (common name from the certificate)
    leftcert=vpnserverCert.pem  # X.509 certificate for server authentication
    leftsendcert=always  # Always send the server's certificate
    leftsubnet=0.0.0.0/0  # Full tunnel, route all client traffic through the server
    right=%any  # Accept connections from any client
    rightid=%fromcert  # Use the client's certificate to identify them
    rightaddresspool=10.0.0.0/24  # IP range for clients
    auto=add  # Load this connection on startup

# Clients
# /etc/ipsec.d/client.conf

config setup
    plutodebug=all
    dumpdir=/var/run/pluto/
    nssdir=/etc/ipsec.d

conn %default
    ikev2=insist  # Force IKEv2
    ike=aes256-sha256-modp2048  # Same encryption settings as the server
    esp=aes256-sha256
    dpdaction=clear
    dpddelay=30
    dpdtimeout=120
    authby=rsasig  # Use RSA signature (certificate-based authentication)

conn myvpn
    left=%defaultroute  # Client's IP address
    leftid=@client1  # Unique identifier for the client (e.g., client certificate ID)
    leftcert=clientCert  # Client's X.509 certificate\
    leftsendcert=always
    right=<VPN_SERVER_PUBLIC_IP>  # Public IP of the VPN server
    rightid=@vpnserver  # VPN server's identifier
    auto=start  # Start this connection automatically




# Generate the certs
openssl req -new -x509 -days 3650 -keyout ca-key.pem -out ca-cert.pem
openssl req -new -keyout vpnserver-key.pem -out vpnserver-req.pem
openssl x509 -req -in vpnserver-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out vpnserverCert.pem
openssl pkcs12 -export -out vpnserver.p12 -inkey vpnserver-key.pem -in vpnserverCert.pem -certfile ca-cert.pem
ipsec import vpnserver.p12

openssl req -new -keyout client-key.pem -out client-req.pem
openssl x509 -req -in client-req.pem -days 3650 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 02 -out clientCert.pem
openssl pkcs12 -export -out client.p12 -inkey client-key.pem -in clientCert.pem -certfile ca-cert.pem
ipsec import client.p12