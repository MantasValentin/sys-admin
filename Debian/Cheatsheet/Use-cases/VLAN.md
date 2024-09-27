# For server
# The primary network interface
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1

# VLAN 10 configuration
auto eth0.10
iface eth0.10 inet static
    address 10.10.10.1
    netmask 255.255.255.0
    vlan-raw-device eth0

# VLAN 20 configuration
auto eth0.20
iface eth0.20 inet static
    address 10.20.20.1
    netmask 255.255.255.0
    vlan-raw-device eth0


# For switch
# Add routes for VLAN subnets
ip route add 10.10.10.0/24 dev eth0.10
ip route add 10.20.20.0/24 dev eth0.20

# Enable ip forwarding 
sudo sed -i "s/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sudo sysctl -p

# Enable NAT for internet access in nftables
table inet nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        oifname "eth0" masquerade
    }
}