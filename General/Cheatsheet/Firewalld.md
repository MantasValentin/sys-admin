# Check if its running
firewall-cmd --state

# Reload after a permanent change
firewall-cmd --reload

# Check the config if it's correct
firewall-cmd --check-config

# Make All non permanent changes to permanent
firewall-cmd --runtime-to-permanent

# List all configurations 
firewall-cmd --list-all --zone=[your-zone]

# Check active or default or all zones
firewall-cmd --get-zones
firewall-cmd --get-active-zones

firewall-cmd --get-default-zone
firewall-cmd --set-default-zone [your-zone]

# Check all active and available services
firewall-cmd --get-services
firewall-cmd --list-services

# Add a service to zone
firewall-cmd --zone=[your-zone] --add-service=[service-name]

# Remove a service
firewall-cmd --zone=[your-zone] --remove-service=[service-name]

# List ports
firewall-cmd --list-ports

# Add port
firewall-cmd --zone=[your-zone] --add-port=[port]/[protocol]

# Remove port
firewall-cmd --zone=[your-zone] --remove-port=[port]/[protocol]

# Add NIC to zone
firewall-cmd --zone=[your-zone] --add-interface=[your-network-device]

# Change NIC zone
firewall-cmd --zone=[your-zone] --change-interface=[your-network-device]

# Remove NIC from zone
firewall-cmd --zone=[your-zone] --remove-interface=[your-network-device]

# Whitelist ip's
firewall-cmd --zone=[your-zone] --add-source=[ip]
firewall-cmd --zone=[your-zone] --add-source=[ip]/[netmask_1-32]

# Blacklist ip's
firewall-cmd --zone=[your-zone] --remove-source=[ip]
firewall-cmd --zone=[your-zone] --remove-source=[ip]/[netmask_1-32]

# Example of rich rule's (Full rules)
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'