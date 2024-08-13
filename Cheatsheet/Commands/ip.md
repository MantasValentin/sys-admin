### ip command usage

##### Show network interfaces and addresses 
- ip address
- ip addr
- ip a

##### Show network interfaces
- ip link

##### Show ip routes 
- ip route

##### Add interface
- sudo ip link add name [interface] type [type_of_interface]
- sudo ip link add name br0 type bridge

##### Add ip address to network interface
- sudo ip addr add [destination] dev [interface]
- sudo ip addr add 192.168.2.1/24 dev eth0

##### Delete ip address from network interface
- sudo ip addr del [destination] dev [interface]
- sudo ip addr del 192.168.4.44/24 dev eth0

##### Start and stop a network interface
- sudo ip link set [interface] up/down
- sudo ip link set enp0s3 up
- sudo ip link set enp0s3 down

##### Add default route
- sudo ip route add default via [gateway] dev [interface]
- sudo ip route add default via 192.168.0.1 dev br0

##### Add route
- sudo ip route add [destination] via [gateway] dev [interface]
- sudo ip route add 192.168.2.0/24 via 192.168.1.1 dev eth0

##### Change route
- sudo ip route change [destination] via [new_gateway]
- sudo ip route change 192.168.2.0/24 via 192.168.1.2

##### Delete route
- sudo ip route del [destination]
- sudo ip route del default via 192.168.4.1 dev enp0s8
- sudo ip route del default