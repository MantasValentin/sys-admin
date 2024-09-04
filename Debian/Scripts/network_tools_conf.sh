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