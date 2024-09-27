#!/bin/bash

# This is a script for setting up a basic security configuration

# Update and upgrade the system
sudo apt-get update -y && DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y -o Dpkg::Options::="--force-confnew"

# Install common security software
packages=(
    libpam-tmpdir       # Creates per-user temporary directories
    apt-listbugs        # Shows bugs before package installation
    apt-listchanges     # Shows changelog before package upgrades
    needrestart         # Checks which daemons need to be restarted after library upgrades
    lynis               # Security auditing tool
    rkhunter            # Rootkit Hunter, scans for rootkits and other malware
    aide                # Advanced Intrusion Detection Environment
    apparmor-utils      # Utilities for controlling AppArmor
    unattended-upgrades # Automatic installation of security upgrades
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

# This ensures that security updates are installed automatically
sudo dpkg-reconfigure -plow unattended-upgrades

# Rename the newly created database to the default location
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Prevent sensitive information from being written to disk in case of a crash
echo "* hard core 0" | sudo tee -a /etc/security/limits.conf

# Configure rkhunter
sudo rkhunter --propupd

# Modify the AIDE configuration to include specific directories
sudo tee -a /etc/aide/aide.conf > /dev/null <<EOT
# AIDE log file
report_url=file:/var/log/aide.log

# Define the directories to check
/etc            R
/bin            R
/sbin           R
/usr/bin        R
/usr/sbin       R
/lib            R
/lib64          R
/boot           R
/root           R
/home           R
/var/spool/cron R


# Exclude other directories
!/tmp
!/proc
!/sys
!/dev
!/run
!/media 
!/mnt
!/var/log
!/var/cache
!/home/*/Downloads
!/home/*/.cache
EOT

# Add and modify the AIDE log file
sudo touch /var/log/aide.log
sudo chown _aide:_aide /var/log/aide.log

# Initialize AIDE with the new configuration
sudo aideinit

# Configure rkhunter adn AIDE scans
(crontab -l 2>/dev/null; echo "0 6 * * * /usr/bin/rkhunter --cronjob --quiet") | crontab -
(crontab -l 2>/dev/null; echo "0 8 * * * /usr/bin/aide --check --config /etc/aide/aide.conf") | crontab -

echo "Security software installation and configuration completed!"