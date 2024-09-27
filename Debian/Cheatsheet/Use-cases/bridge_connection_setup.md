#

sudo apt-get install bridge-utils

# /etc/sysctl.conf

net.ipv4.ip_forward = 1

sudo sysctl -p

# /etc/nftables

#!/usr/sbin/nft -f

flush ruleset

table inet filter {
	chain input {
		type filter hook input priority filter;
	}
	chain forward {
		type filter hook forward priority filter; policy drop;
		ip saddr 192.168.0.0/24 ip daddr 192.168.1.0/24 accept
        ip saddr 192.168.1.0/24 ip daddr 192.168.0.0/24 accept
	}
	chain output {
		type filter hook output priority filter;
	}
}

table inet nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        oifname "ens33" masquerade
	    oifname "ens34" masquerade
    }
}

# /etc/network/interfaces

auto br0
iface br0 inet static
	address 192.168.1.102
	netmaks 255.255.255.0
	gateway 192.168.1.1
	bridge_ports ens33 ens34

iface br0 inet static
    address 192.168.0.170
    netmask 255.255.255.0

auto ens33
iface ens33 inet manual

auto ens34
iface ens34 inet manual

# ip route

default via 192.168.1.1 dev br0 onlink 
192.168.0.0/24 dev br0 proto kernel scope link src 192.168.0.170 
192.168.1.0/24 dev br0 proto kernel scope link src 192.168.1.102

# ip a

2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 1000
    link/ether 00:0c:29:7d:a3:c6 brd ff:ff:ff:ff:ff:ff
    altname enp2s1
3: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 1000
    link/ether 00:0c:29:7d:a3:d0 brd ff:ff:ff:ff:ff:ff
    altname enp2s2
6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether da:a9:a6:2c:8c:90 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.102/24 brd 192.168.1.255 scope global br0
       valid_lft forever preferred_lft forever
    inet 192.168.0.170/24 brd 192.168.0.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::d8a9:a6ff:fe2c:8c90/64 scope link 
       valid_lft forever preferred_lft forever

# Client routing

sudo ip route add 192.168.1.0/24 via 192.168.0.170