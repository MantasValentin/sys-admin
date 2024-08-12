#!/bin/bash

# This is a script for setting up a basic DNS server

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install DNS server
sudo apt-get install -y \
    bind9

# Configure bind9
## Logging
sudo tee -a /etc/bind/named.conf > /dev/null <<EOT
logging {
    channel default_log {
        file "/var/log/named/default.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel query_log {
        file "/var/log/named/query.log" versions 3 size 5m;
        severity info;
        print-time yes;
    };
    category default { default_log; };
    category queries { query_log; };
};
EOT

## DNS query resolving
sudo awk '    
    /directory "\/var\/cache\/bind";/ {
        print $0 "\n\trecursion yes;\n\tallow-query { any; };\n\tlisten-on { any; };"
        next
    }
    
    /\/\/ forwarders {/ {
        print "\tforwarders {";
        print "\t\t1.1.1.1;";
        print "\t\t1.0.0.1;";
        print "\t\t8.8.8.8;";
        print "\t\t8.8.4.4;";
        print "\t};";
        next;
    }
    /\/\/ \t0\.0\.0\.0;/ { next; }
    /\/\/ };/ { next; }
    
    # Print all other lines
    { print }
' /etc/bind/named.conf.options > /tmp/named.conf.options.tmp 
sudo mv /tmp/named.conf.options.tmp /etc/bind/named.conf.options
sudo rm -rf /tmp/named.conf.options.tmp

## log files
sudo mkdir /var/log/named
sudo chown bind:bind /var/log/named

sudo systemctl restart bind9

# Disable NetworkManager for easier dns resolution configuration
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

sudo tee /etc/resolv.conf > /dev/null <<EOT
nameserver 127.0.0.1
EOT

# Networking configuration
## Variables
INTERFACE="enp0s3"
ADDRESS="192.168.0.120"
NETMASK="255.255.255.0"
GATEWAY="192.168.0.1"

## Configuration to be added
config="
auto $INTERFACE
iface $INTERFACE inet static
    address $ADDRESS
    netmask $NETMASK
    gateway $GATEWAY
"
## Append the configuration to the file using tee -a
echo "$config" | sudo tee -a "/etc/network/interfaces"

sudo dhclient -r

sudo systemctl restart networking

echo "DNS server installation and configuration completed!"