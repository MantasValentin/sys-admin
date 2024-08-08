#!/bin/bash

# This is a script for setting up a basic DHCP server

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install DHCP server
sudo apt-get install -y \
    isc-dhcp-server

# Configure isc-dhcp-server
sudo tee -a /etc/dhcp/dhcpd.conf > /dev/null <<EOT
subnet 192.168.1.0 netmask 255.255.255.0 {
 range 192.168.1.100 192.168.1.200;
 option routers 192.168.1.1;
 option domain-name-server 192.168.1.1;
}
EOT

# Nftable routing configuration 
sudo tee /etc/nftables.conf > /dev/null <<EOT
#!/usr/sbin/nft -f

flush ruleset

table ip nat {
    chain prerouting {
        type nat hook prerouting priority 0;
    }
    chain postrouting {
        type nat hook postrouting priority 100;
        oifname "enp0s3" masquerade
    }
}

table ip filter {
    chain input {
        type filter hook input priority 0;
        policy accept;
    }
    chain forward {
        type filter hook forward priority 0;
        policy accept;
        iifname "enp0s8" oifname "enp0s3" accept
        iifname "enp0s3" oifname "enp0s8" ct state related,established accept
    }
    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}
EOT

sudo systemctl enable nftables
sudo systemctl start nftables

# Allow ipv4 routing

sudo sed -i "s/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sudo sysctl -p

# Networking configuration
## Variables
INTERFACE="enp0s8"
ADDRESS="192.168.1.1"
NETMASK="255.255.255.0"

sudo sed -i "s/^INTERFACESv4=\"\"/INTERFACESv4=\"$INTERFACE\"/" /etc/default/isc-dhcp-server

## Configuration to be added
config="
auto $INTERFACE
iface $INTERFACE inet static
    address $ADDRESS
    netmask $NETMASK
"
## Append the configuration to the file using tee -a
echo "$config" | sudo tee -a "/etc/network/interfaces"

sudo systemctl restart networking

sudo systemctl enable isc-dhcp-server
sudo systemctl restart isc-dhcp-server

echo "DHCP server installation and configuration completed!"