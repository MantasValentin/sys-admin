# Install fail2ban
sudo apt update
sudo apt install fail2ban -y

# Configure /etc/fail2ban/jail.local
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

# Lounch fail2ban with configuration
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban