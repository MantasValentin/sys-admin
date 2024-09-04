#!/bin/bash

# This is a script for setting up a basic network configuration

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install common networking software
packages=(
    "nftables"               # Administration tool for packet filtering and NAT
)

# Loop through each package and attempt to install it
echo "Installing packages"
for package in "${packages[@]}"; do
    echo "Installing $package..."
    sudo apt-get install -y
    
    # Check the exit status of the last command
    if [ $? -eq 0 ]; then
        echo "$package installed successfully."
    else
        echo "Failed to install $package."
    fi
done
echo "Finished installing packages"

# Configure nftables
echo "Configuring nftables"

## Create nftables configuration file
sudo tee /etc/nftables.conf > /dev/null <<EOT
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    # Set for recent IP addresses that have been flagged for port scanning
    set port_scanners {
        type ipv4_addr
        size 65536
        flags dynamic,timeout
        timeout 10m
    }

    # Set for counting connection attempts per IP
    set conn_counter {
        type ipv4_addr
        size 65536
        flags dynamic,timeout
        timeout 1m
    }

    # Trusted ip's for unrestricted connections
    set trusted-ip {
        type ipv4_addr
        elements = { 0.0.0.0 }
    }

    chain input {
        type filter hook input priority filter; policy drop;

        # Accept any localhost traffic
        iifname "lo" accept 
        # Accept traffic originated from us
        ct state {established, related} accept
        # Drop invalid packets
        ct state invalid log prefix "WARNING - Invalid Packet: " level warn drop

        # Port scan detection
        tcp flags & (fin|syn|rst|ack) == syn ct state new \
            add @conn_counter { ip saddr } \
            limit rate over 10/second \
            add @port_scanners { ip saddr } \
            drop

        # Drop all traffic from detected port scanners
        ip saddr @port_scanners drop

        # Prevent ping floods - limit rate of ICMP and ICMPv6 echo requests
        meta l4proto icmp icmp type echo-request limit rate over 10/second burst 4 packets drop
        meta l4proto ipv6-icmp icmpv6 type echo-request limit rate over 10/second burst 4 packets drop

        # Accept necessary ICMP and ICMPv6 traffic
        meta l4proto ipv6-icmp accept
        meta l4proto icmp accept
        ip protocol igmp accept

        # Allow all SSH connections from trusted ip's
        tcp dport 22 ip saddr @trusted-ip accept
        # Rate limiting for SSH connections to prevent brute force
        tcp dport 22 ct state new limit rate 3/minute burst 10 packets accept
        # Log and drop SSH connections that exceed the rate limit
        tcp dport 22 log prefix "WARNING - SSH rate limiting: " level warn drop

        # Accept DHCP traffic
        udp dport { 67, 68 } accept
        # Accept DNS traffic
        tcp dport 53 accept
        udp dport 53 accept
        # Accept mDNS queries (IPv4 and IPv6)
        udp dport mdns ip6 daddr ff02::fb accept 
        udp dport mdns ip daddr 224.0.0.251 accept

        # Service ports (uncomment as needed)
        # tcp dport { 80, 443 } accept;  # HTTP/HTTPS
        # tcp dport 3306 accept;  # MySQL/MariaDB
        # tcp dport 5432 accept;  # PostgreSQL
        # tcp dport 27017 accept;  # MongoDB
        # tcp dport 6379 accept;  # Redis
        # tcp dport 1521 accept;  # Oracle
        # tcp dport 1433 accept;  # Microsoft SQL Server
        # tcp dport 9042 accept;  # Cassandra
        # tcp dport { 5044, 5601, 9200, 9300 } accept;  # Elasticsearch, Kibana, Logstash
    }
    chain forward {
        type filter hook forward priority filter; policy drop;
    }
    chain output {
        type filter hook output priority filter; policy accept;
    }
}
EOT

## Start nftables
sudo nft -f /etc/nftables.conf
sudo systemctl enable nftables
sudo systemctl restart nftables