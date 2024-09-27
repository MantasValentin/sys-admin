# List Connections
nmcli connection show

# Activate Connection
nmcli connection up <connection-name>

# Deactivate Connection
nmcli connection down <connection-name>

# Add ethernet connection
nmcli connection add type ethernet con-name <connection-name> ifname <interface-name>

# Modify connection
nmcli connection modify <connection-name> <setting>.<property> <value>

# Delete connection
nmcli connection delete <connection-name>

# Check devices
nmcli device status

# Check Wifi
nmcli device wifi list

# Connect to wifi
nmcli device wifi connect <SSID> password <password>

# Enable disable networking
nmcli networking on
nmcli networking off

# Enable disable wifi
nmcli radio wifi on
nmcli radio wifi off

# Reload connection to apply changes
nmcli connection reload <connection-name>

# Show general Network Manager status
nmcli general status

# Set static Ip
nmcli connection modify <connection-name> ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.method manual

# VLAN
nmcli connection add type vlan con-name vlan10 dev eth0 id 10 ip4 10.10.10.1/24

nmcli connection add type vlan con-name vlan10 dev eth0 id 10 ip4 10.10.10.2/24