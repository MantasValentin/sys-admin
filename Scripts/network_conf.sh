#!/bin/bash

# This is a script for setting up a basic network configuration

# Update and upgrade the system
sudo apt-get update -y && DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y -o Dpkg::Options::="--force-confnew"

# Install common networking software
packages=(
    "net-tools"              # Provides classic networking tools like ifconfig, netstat, route
    "traceroute"             # Traces the route packets take to a network host
    "nmap"                   # Network exploration tool and security scanner
    "wireshark"              # Network protocol analyzer
    "iperf3"                 # Tool for active measurements of network performance
    "tcpdump"                # Command-line packet analyzer
    "netcat"                 # Utility for reading from and writing to network connections
    "curl"                   # Tool for transferring data using various protocols
    "wget"                   # Tool for retrieving files using HTTP, HTTPS, and FTP
    "whois"                  # Client for the WHOIS directory service
    "dnsutils"               # DNS utilities including dig and nslookup
    "nftables"               # Administration tool for packet filtering and NAT
    "openssh-server"         # Secure shell server for remote access
    "fail2ban"               # Added for additional SSH security
)

# Loop through each package and attempt to install it
echo "Installing packages"
for package in "${packages[@]}"; do
    echo "Installing $package..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confnew" "$package"
    
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

# Trusted ip's for less trafic restrictions
# define trusted_ips = { } # doesn't work

table inet filter {
    chain input {
        type filter hook input priority 0;

        # Default policy
        policy drop;

        # Allow established/related connections
        ct state {established, related} accept;

        # Allow loopback
        iifname "lo" accept;

        # Drop invalid packets
        ct state invalid log prefix "WARNING - Invalid Packet: " level warn drop;

        # DDoS protection (SYN flood), ip based rate limiting
        # ip saddr . ip protocol . tcp dport {
        #    limit rate 2/second burst 10 packets;
        # } accept; # doesn't work
        # ip saddr @trusted_ips tcp flags & (fin|syn|rst|ack) == syn limit rate 20/second burst 100 packets accept; # doesn't work
        ct state new tcp flags & (fin|syn|rst|ack) == syn limit rate 2/second burst 10 packets accept;        
        ct state new tcp flags & (fin|syn|rst|ack) == syn counter log prefix "EMERGENCY - Potential DDoS: " level emerg drop;

        # Protect against port scanning partialy
        tcp flags & (fin|syn|rst|ack) == fin|syn|rst|ack log prefix "CRITICAL - Port Scan Detected: " level crit drop;
        tcp flags & (fin|syn|rst|ack) == 0 log prefix "CRITICAL - Port Scan Detected: " level crit drop;

        # Ip based rate limiting for SSH connections
        # ip saddr @trusted_ips tcp dport 22 ct state new limit rate 10/minute burst 10 packets accept; # doesn't work
        tcp dport 22 ct state new limit rate 3/minute burst 5 packets log prefix "INFO - New SSH Connection: " level info accept;
        tcp dport 22 log prefix "Warning - Failed SSH Connection: " level warn drop;

        # Service ports (uncomment as needed)
        # tcp dport {80, 443} accept;  # HTTP/HTTPS
        # udp dport 53 accept;  # DNS
        # tcp dport 53 accept;  # DNS
        # udp dport 67 accept;  # DHCP
        # tcp dport 3306 accept;  # MySQL/MariaDB
        # tcp dport 5432 accept;  # PostgreSQL
        # tcp dport 27017 accept;  # MongoDB
        # tcp dport 6379 accept;  # Redis
        # tcp dport 1521 accept;  # Oracle
        # tcp dport 1433 accept;  # Microsoft SQL Server
        # tcp dport 9042 accept;  # Cassandra
        # tcp dport { 5044, 5601, 9200, 9300} accept;  # Elasticsearch, Kibana, Logstash

        # Allow ICMP (ping)
        icmp type { echo-request, destination-unreachable, time-exceeded } limit rate 1/second accept;
        icmp type { echo-request, destination-unreachable, time-exceeded } log prefix "WARNING - High ICMP Rate: " level warn drop;

        # Log dropped packets
        log prefix "nftables-Dropped: " level debug drop;
    }

    chain forward {
        type filter hook forward priority 0;
        policy drop;
    }

    chain output {
        type filter hook output priority 0;
        policy accept;
    }
}
EOT

## Enable and start nftables service
sudo systemctl enable nftables
sudo systemctl start nftables

# SSH server
echo "Configuring SSH server"

## SSH server configuration
sudo awk '
    /^#MaxAuthTries 6$/ { print "MaxAuthTries 3"; next }
    /^#MaxSessions 10$/ { print "MaxSessions 2"; next }
    /^X11Forwarding yes$/ { print "X11Forwarding no"; next }
    /^#AllowAgentForwarding yes$/ { print "AllowAgentForwarding no"; next }
    /^#AllowTcpForwarding yes$/ { print "AllowTcpForwarding no"; next }
    /^#TCPKeepAlive yes$/ { print "TCPKeepAlive no"; next }
    /^#Compression delayed$/ { print "Compression no"; next }
    /^#ClientAliveCountMax 3$/ { print "ClientAliveCountMax 2"; next }
    /^#LogLevel INFO$/ { print "LogLevel VERBOSE"; next }
    /^#ClientAliveInterval 0$/ { print "ClientAliveInterval 300"; next }
    /^#LoginGraceTime 2m$/ { print "LoginGraceTime 30s"; next }
    { print }
' /etc/ssh/sshd_config > /tmp/sshd_config.tmp 
sudo mv /tmp/sshd_config.tmp /etc/ssh/sshd_config
sudo rm -rf /tmp/sshd_config.tmp


## Start SSH server 
sudo systemctl enable ssh
sudo systemctl start ssh

# Fail2ban
echo "Configuring Fail2ban"

## Fail2ban configuration

## Start Fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Network configuration installation and configuration completed!"