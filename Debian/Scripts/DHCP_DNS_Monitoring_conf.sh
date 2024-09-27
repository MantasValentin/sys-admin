#!/bin/bash

# This is a script for setting up a bind9 dns server a kea dhcp server and a stork monitoring server.

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Prerequesites for getting the stork setup package
sudo apt-get install curl -y

# Get the setup package for stork
curl -1sLf 'https://dl.cloudsmith.io/public/isc/stork/cfg/setup/bash.deb.sh' | sudo bash

# Install bind dns server, kea dhcp server, stork monitoring server
sudo apt-get install -y bind9 kea isc-stork-server isc-stork-agent postgresql

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

# Start service
sudo systemctl enable bind9
sudo systemctl restart bind9

# Disable NetworkManager for easier dns resolution configuration
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

sudo tee /etc/resolv.conf > /dev/null <<EOT
nameserver 127.0.0.1
EOT

# Networking configuration
## Variables
INTERFACE="ens33"
ADDRESS="192.168.0.150"
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

sudo dhclient
sudo dhclient -r

sudo systemctl restart networking

echo "DNS server installation and configuration completed!"

# Configure kea
sudo tee /etc/kea/kea-dhcp4.conf > /dev/null <<EOT
{
  "Dhcp4": {
    "valid-lifetime": 4000,
    "subnet4": [
      {
        "subnet": "192.168.2.0/24",
        "pools": [
          {
            "pool": "192.168.2.100 - 192.168.2.200"
          }
        ],
        "option-data": [
          {
            "name": "routers",
            "data": "192.168.2.1"
          },
          {
            "name": "domain-name-servers",
            "data": "192.168.2.1"
          }
        ]
      }
    ],
    "interfaces-config": {
      "interfaces": [ "ens34" ]
    }
  }
}
EOT

# Networking configuration
## Variables
INTERFACE="ens34"
ADDRESS="192.168.2.1"
NETMASK="255.255.255.0"

## Configuration to be added
config="
auto $INTERFACE
iface $INTERFACE inet static
    address $ADDRESS
    netmask $NETMASK
"

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
        oifname "ens33" masquerade
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
        iifname "ens34" oifname "ens33" accept
        iifname "ens33" oifname "ens34" ct state related,established accept
    }
    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}
EOT

sudo systemctl enable nftables
sudo systemctl restart nftables

## Append the configuration to the file using tee -a
echo "$config" | sudo tee -a "/etc/network/interfaces"

sudo systemctl restart networking

# Allow ipv4 forwarding
sudo sed -i "s/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sudo sysctl -p

# Start service
sudo systemctl enable kea-dhcp4-server
sudo systemctl restart kea-dhcp4-server

# Configure stork
## Configure postgresql
sudo sed -i "s/^local   all             all                                     peer/local   all             all                                     md5/" /etc/postgresql/15/main/pg_hba.conf

sudo systemctl enable postgresql@15-main
sudo systemctl restart postgresql@15-main

stork-tool db-create --db-name stork --db-user stork

sudo systemctl enable isc-stork-server
sudo systemctl restart isc-stork-server

sudo su stork-agent -s /bin/sh -c 'stork-agent register --server-url http://stork.example.org:8080'

sudo systemctl enable isc-stork-agent
sudo systemctl restart isc-stork-agent