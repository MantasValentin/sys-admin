# Base nftables configuration 
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
	chain input {
		type filter hook input priority filter;
	}
	chain forward {
		type filter hook forward priority filter;
	}
	chain output {
		type filter hook output priority filter;
	}
}

# Create a list of blocked ip's
# Delete or add to elemements, or specify timeout
table inet filter {
    chain input {
        type filter hook input priority 0; policy accept;
        ip saddr @ip-list drop
    }

    set ip-list {
        type ipv4_addr
        elements = { 0.0.0.0 }
#        flags timeout
#        timeout 1h
    }
}

#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    # Set for recent IP addresses that have been flagged for port scanning
    set port_scanners {
        type ipv4_addr
        size 65536
        flags dynamic,timeout
        timeout 1d
    }

    # Set for counting connection attempts per IP
    set conn_counter {
        type ipv4_addr
        size 65536
        flags dynamic,timeout
        timeout 1m
    }

    # Trusted ip's for unrestricted connections
    set trusted-ip {
        type ipv4_addr
        elements = { 0.0.0.0 }
    }

    chain input {
        type filter hook input priority filter; policy drop;

        # Accept any localhost traffic
        iifname "lo" accept 
        # Accept traffic originated from us
        ct state {established, related} accept
        # Drop invalid packets
        ct state invalid log prefix "WARNING - Invalid Packet: " level warn drop

        # Allow all connections from trusted ip's
        ip saddr @trusted-ip accept

        # Port scan detection
        tcp ct state new, untracked \
            add @conn_counter { ip saddr counter } \
            limit rate over 10/minute \
            add @port_scanners { ip saddr } \
            drop

        # Drop all traffic from detected port scanners
        ip saddr @port_scanners drop

        # Prevent ping floods - limit rate of ICMP and ICMPv6 echo requests
        meta l4proto icmp icmp type echo-request limit rate over 10/second burst 4 packets drop
        meta l4proto ipv6-icmp icmpv6 type echo-request limit rate over 10/second burst 4 packets drop

        # Accept necessary ICMP and ICMPv6 traffic
        meta l4proto ipv6-icmp accept
        meta l4proto icmp accept
        ip protocol igmp accept

        # Rate limiting for SSH connections to prevent brute force
        tcp dport 22 ct state new limit rate 3/minute burst 10 packets accept
        # Log and drop SSH connections that exceed the rate limit
        tcp dport 22 log prefix "WARNING - SSH rate limiting: " level warn drop

        # Accept DHCP traffic
        udp dport { 67, 68 } accept
        # Accept DNS traffic
        tcp dport 53 accept
        udp dport 53 accept
        # Accept mDNS queries (IPv4 and IPv6)
        udp dport 5353 ip6 daddr ff02::fb accept 
        udp dport 5353 ip daddr 224.0.0.251 accept

        # Service ports (uncomment as needed)
        # tcp dport { 80, 443 } accept;  # HTTP/HTTPS
        # tcp dport 3306 accept;  # MySQL/MariaDB
        # tcp dport 5432 accept;  # PostgreSQL
        # tcp dport 27017 accept;  # MongoDB
        # tcp dport 6379 accept;  # Redis
        # tcp dport 1521 accept;  # Oracle
        # tcp dport 1433 accept;  # Microsoft SQL Server
        # tcp dport 9042 accept;  # Cassandra
        # tcp dport { 5044, 5601, 9200, 9300 } accept;  # Elasticsearch, Kibana, Logstash
    }
    chain forward {
        type filter hook forward priority filter; policy drop;
    }
    chain output {
        type filter hook output priority filter; policy accept;
    }
}



Jump

When using jumps in configuration file, it is necessary to define the target chain first. Otherwise one could end up with Error: Could not process rule: No such file or directory.

table inet my_table {
    chain web {
        tcp dport http accept
        tcp dport 8080 accept
    }
    chain my_input {
        type filter hook input priority filter;
        ip saddr 10.0.2.0/24 jump web
        drop
    }
}






Different rules for different interfaces

If your box has more than one network interface, and you would like to use different rules for different interfaces, you may want to use a "dispatching" filter chain, and then interface-specific filter chains. For example, let us assume your box acts as a home router, you want to run a web server accessible over the LAN (interface enp3s0), but not from the public internet (interface enp2s0), you may want to consider a structure like this:

table inet my_table {
  chain my_input { # this chain serves as a dispatcher
    type filter hook input priority filter;

    iif lo accept comment "always accept loopback"
    iifname enp2s0 jump my_input_public
    iifname enp3s0 jump my_input_private

    reject with icmpx port-unreachable comment "refuse traffic from all other interfaces"
  }
  chain my_input_public { # rules applicable to public interface interface
    ct state {established,related} accept
    ct state invalid drop
    udp dport bootpc accept
    tcp dport bootpc accept
    reject with icmpx port-unreachable comment "all other traffic"
  }
  chain my_input_private {
    ct state {established,related} accept
    ct state invalid drop
    udp dport bootpc accept
    tcp dport bootpc accept
    tcp port http accept
    tcp port https accept
    reject with icmpx port-unreachable comment "all other traffic"
  }
  chain my_output { # we let everything out
    type filter hook output priority filter;
    accept
  }
}






Masquerading

nftables has a special keyword masquerade "where the source address is automagically set to the address of the output interface" (source). This is particularly useful for situations in which the IP address of the interface is unpredictable or unstable, such as the upstream interface of routers connecting to many ISPs. Without it, the Network Address Translation rules would have to be updated every time the IP address of the interface changed.

To use it:

    make sure masquerading is enabled in the kernel (true if you use the default kernel), otherwise during kernel configuration, set CONFIG_NFT_MASQ=m.
    the masquerade keyword can only be used in chains of type nat.
    masquerading is a kind of source NAT, so only works in the output path.

Example for a machine with two interfaces: LAN connected to enp3s0, and public internet connected to enp2s0:

table inet my_nat {
  chain my_masquerade {
    type nat hook postrouting priority srcnat;
    oifname "enp2s0" masquerade
  }
}





NAT with port forwarding

This example will masquerade traffic exiting through a WAN interface called eth0 and forward ports 22 and 80 to 10.0.0.2. You will need to set net.ipv4.ip_forward to 1 via sysctl.

table nat {
    chain prerouting {
        type nat hook prerouting priority dstnat;
        iif eth0 tcp dport {22, 80} dnat to 10.0.0.2
    }
    chain postrouting {
        type nat hook postrouting priority srcnat;
        oif eth0 masquerade
    }
}





Count new connections per IP

Use this snippet to count HTTPS connections:

/etc/nftables.conf

table inet filter {
    set https {
        type ipv4_addr;
        flags dynamic;
        size 65536;
        timeout 60m;
    }

    chain input {
        type filter hook input priority filter;
        ct state new tcp dport 443 update @https { ip saddr counter }
    }
}





Dynamic blackhole

Use this snippet to drop all HTTPS connections for 1 minute from a source IP (or /64 IPv6 range) that exceeds the limit of 10/second.

/etc/nftables.conf

table inet dev {
    set blackhole_ipv4 {
        type ipv4_addr;
        flags dynamic, timeout;
        size 65536;
    }
    set blackhole_ipv6 {
        type ipv6_addr;
        flags dynamic, timeout;
        size 65536;
    }

    chain input {
        type filter hook input priority filter; policy accept;
        ct state new tcp dport 443 \
                meter flood_ipv4 size 128000 { ip saddr timeout 10s limit rate over 10/second } \
                add @blackhole_ipv4 { ip saddr timeout 1m }
        ct state new tcp dport 443 \
                meter flood_ipv6 size 128000 { ip6 saddr and ffff:ffff:ffff:ffff:: timeout 10s limit rate over 10/second } \
                add @blackhole_ipv6 { ip6 saddr and ffff:ffff:ffff:ffff:: timeout 1m }

        ip saddr @blackhole_ipv4 counter drop
        ip6 saddr and ffff:ffff:ffff:ffff:: @blackhole_ipv6 counter drop
    }
}






Single machine

Flush the current ruleset:

# nft flush ruleset

Add a table:

# nft add table inet my_table

Add the input, forward, and output base chains. The policy for input and forward will be to drop. The policy for output will be to accept.

# nft add chain inet my_table my_input '{ type filter hook input priority 0 ; policy drop ; }'
# nft add chain inet my_table my_forward '{ type filter hook forward priority 0 ; policy drop ; }'
# nft add chain inet my_table my_output '{ type filter hook output priority 0 ; policy accept ; }'

Add two regular chains that will be associated with tcp and udp:

# nft add chain inet my_table my_tcp_chain
# nft add chain inet my_table my_udp_chain

Related and established traffic will be accepted:

# nft add rule inet my_table my_input ct state related,established accept

All loopback interface traffic will be accepted:

# nft add rule inet my_table my_input iif lo accept

Drop any invalid traffic:

# nft add rule inet my_table my_input ct state invalid drop

Accept ICMP and IGMP:

# nft add rule inet my_table my_input meta l4proto ipv6-icmp accept
# nft add rule inet my_table my_input meta l4proto icmp accept
# nft add rule inet my_table my_input ip protocol igmp accept

New udp traffic will jump to the UDP chain:

# nft add rule inet my_table my_input meta l4proto udp ct state new jump my_udp_chain

New tcp traffic will jump to the TCP chain:

# nft add rule inet my_table my_input 'meta l4proto tcp tcp flags & (fin|syn|rst|ack) == syn ct state new jump my_tcp_chain'

Reject all traffic that was not processed by other rules:

# nft add rule inet my_table my_input meta l4proto udp reject
# nft add rule inet my_table my_input meta l4proto tcp reject with tcp reset
# nft add rule inet my_table my_input counter reject with icmpx port-unreachable

At this point you should decide what ports you want to open to incoming connections, which are handled by the TCP and UDP chains. For example to open connections for a web server add:

# nft add rule inet my_table my_tcp_chain tcp dport 80 accept

To accept HTTPS connections for a webserver on port 443:

# nft add rule inet my_table my_tcp_chain tcp dport 443 accept

To accept SSH traffic on port 22:

# nft add rule inet my_table my_tcp_chain tcp dport 22 accept

To accept incoming DNS requests:

# nft add rule inet my_table my_tcp_chain tcp dport 53 accept
# nft add rule inet my_table my_udp_chain udp dport 53 accept
