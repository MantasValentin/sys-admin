# VLAN
nmcli connection add type vlan con-name vlan10 dev eth0 id 10 ip4 10.10.10.1/24

nmcli connection add type vlan con-name vlan10 dev eth0 id 10 ip4 10.10.10.2/24