# Show network interfaces and addresses 
ip address show
ip addr show
ip addr
ip a

# Add ip address to network interface
sudo ip addr add dev wg0 192.168.2.1/24

# Delete ip address
sudo ip addr del 192.168.4.44/24 dev enp0s3

# Show network interfaces
ip link show

# Start and stop a network interface
sudo ip link set enp0s3 upd
sudo ip link set enp0s3 down

# Show ip routes 
ip route

# Add route
sudo ip addr add 192.168.121.1/24 dev enp0s8

# Delete route
sudo ip route delete default via 192.168.4.1 dev enp0s8