# Check if its running
firewall-cmd --state

# Reload after a permanent change
firewall-cmd --reload

# Check the config if it's correct
firewall-cmd --check-config

# Make All non permanent changes to permanent
firewall-cmd --runtime-to-permanent
# or add
--permanent

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

# Add new policy
firewall-cmd --permanent --new-policy [your-policy]

# Setting the default target of policy
target: ACCEPT,DROP,REJECT,CONTINUE
firewall-cmd --policy=[your-policy] --set-target [target]

# Example of rich rule's (Full rules)
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'


# Traffic forwarding
firewall-cmd --permanent --new-policy <example_policy>
firewall-cmd --permanent --policy=<example_policy> --add-ingress-zone=HOST
firewall-cmd --permanent --policy=<example_policy> --add-egress-zone=ANY
firewall-cmd --permanent --policy=<example_policy> --add-rich-rule='rule
family="ipv4" destination address="192.0.2.1" forward-port port="443" protocol="tcp" to-port="443" to-addr="192.51.100.20"'

echo "net.ipv4.conf.all.route_localnet=1" > /etc/sysctl.d/90-enable-route-localnet.conf
sysctl -p /etc/sysctl.d/90-enable-route-localnet.conf

# Routing

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/95-IPv4-forwarding.conf
sysctl -p /etc/sysctl.d/95-IPv4-forwarding.conf