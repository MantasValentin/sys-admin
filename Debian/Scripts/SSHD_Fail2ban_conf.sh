#!/bin/bash

# This is a script for setting up ssh server with fail2ban

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install revelent software
sudo apt-get install openssh-server nftables fail2ban -y

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

## Start SSH server 
sudo systemctl enable ssh
sudo systemctl restart ssh

# nftables
echo "Configuring nftables"

## nftables configuration

## Enable and start nftables service
sudo systemctl enable nftables
sudo systemctl restart nftables

# Fail2ban
echo "Configuring Fail2ban"

## Fail2ban configuration
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOT
[sshd]
enabled = true
port 	= ssh
filter 	= sshd
backend	= systemd
journalmatch = _SYSTEMD_UNIT=ssh.service
maxretry = 3
bantime = 3600
findtime = 600

action = nftables-multiport[port="ssh", protocol="tcp", name="sshd"]
EOT

## Start Fail2ban
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban