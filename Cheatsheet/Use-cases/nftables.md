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

# Trusted ip's for less trafic restrictions
define trusted_ips = { 0.0.0.0 }

table inet filter {
    chain input {
        type filter hook input priority 0;

        # Default policy
        policy drop;

        # Allow established/related connections
        ct state {established, related} accept;

        # Allow loopback
        iifname "lo" accept;

        # Drop invalid packets
        ct state invalid log prefix "WARNING - Invalid Packet: " level warn drop;

        # DDoS protection (SYN flood), ip based rate limiting
        # ip saddr . ip protocol . tcp dport {
        #    limit rate 2/second burst 10 packets;
        # } accept; # doesn't work
        # ip saddr @trusted_ips tcp flags & (fin|syn|rst|ack) == syn limit rate 20/second burst 100 packets accept; # doesn't work
        ct state new tcp flags & (fin|syn|rst|ack) == syn limit rate 2/second burst 10 packets accept;        
        ct state new tcp flags & (fin|syn|rst|ack) == syn counter log prefix "EMERGENCY - Potential DDoS: " level emerg drop;

        # Protect against port scanning partialy
        tcp flags & (fin|syn|rst|ack) == fin|syn|rst|ack log prefix "CRITICAL - Port Scan Detected: " level crit drop;
        tcp flags & (fin|syn|rst|ack) == 0 log prefix "CRITICAL - Port Scan Detected: " level crit drop;

        # Ip based rate limiting for SSH connections
        # ip saddr @trusted_ips tcp dport 22 ct state new limit rate 10/minute burst 10 packets accept; # doesn't work
        tcp dport 22 ct state new limit rate 3/minute burst 5 packets log prefix "INFO - New SSH Connection: " level info accept;
        tcp dport 22 log prefix "Warning - Failed SSH Connection: " level warn drop;

        # Service ports (uncomment as needed)
        # tcp dport {80, 443} accept;  # HTTP/HTTPS
        # udp dport 53 accept;  # DNS
        # tcp dport 53 accept;  # DNS
        # udp dport {67, 68} accept;  # DHCP: 67 for server, 68 for client
        # tcp dport 3306 accept;  # MySQL/MariaDB
        # tcp dport 5432 accept;  # PostgreSQL
        # tcp dport 27017 accept;  # MongoDB
        # tcp dport 6379 accept;  # Redis
        # tcp dport 1521 accept;  # Oracle
        # tcp dport 1433 accept;  # Microsoft SQL Server
        # tcp dport 9042 accept;  # Cassandra
        # tcp dport { 5044, 5601, 9200, 9300} accept;  # Elasticsearch, Kibana, Logstash

        # Allow ICMP (ping)
        icmp type { echo-request, destination-unreachable, time-exceeded } limit rate 1/second accept;
        icmp type { echo-request, destination-unreachable, time-exceeded } log prefix "WARNING - High ICMP Rate: " level warn drop;

        # Log dropped packets
        log prefix "nftables-Dropped: " level debug drop;
    }
}

#!/usr/sbin/nft -f

flush ruleset

# Trusted ip's for less trafic restrictions
define trusted_ips = { 0.0.0.0 }

table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;

        # Allow loopback
        iifname "lo" accept;
        # Allow established/related connections
        ct state {established, related} accept;
        # Drop invalid packets
        ct state invalid log prefix "WARNING - Invalid Packet: " level warn drop;

        # DDoS protection (SYN flood), ip based rate limiting
        # ip saddr . ip protocol . tcp dport {
        #    limit rate 2/second burst 10 packets;
        # } accept; # doesn't work
        # ip saddr @trusted_ips tcp flags & (fin|syn|rst|ack) == syn limit rate 20/second burst 100 packets accept; # doesn't work
        ct state new tcp flags & (fin|syn|rst|ack) == syn limit rate 2/second burst 10 packets accept;        
        ct state new tcp flags & (fin|syn|rst|ack) == syn counter log prefix "EMERGENCY - Potential DDoS: " level emerg drop;

        # Protect against port scanning partialy
        tcp flags & (fin|syn|rst|ack) == fin|syn|rst|ack log prefix "CRITICAL - Port Scan Detected: " level crit drop;
        tcp flags & (fin|syn|rst|ack) == 0 log prefix "CRITICAL - Port Scan Detected: " level crit drop;

        # Ip based rate limiting for SSH connections
        # ip saddr @trusted_ips tcp dport 22 ct state new limit rate 10/minute burst 10 packets accept; # doesn't work
        tcp dport 22 ct state new limit rate 3/minute burst 5 packets log prefix "INFO - New SSH Connection: " level info accept;
        tcp dport 22 log prefix "Warning - Failed SSH Connection: " level warn drop;

        # Service ports (uncomment as needed)
        # tcp dport {80, 443} accept;  # HTTP/HTTPS
        # udp dport 53 accept;  # DNS
        # tcp dport 53 accept;  # DNS
        # udp dport {67, 68} accept;  # DHCP: 67 for server, 68 for client
        # tcp dport 3306 accept;  # MySQL/MariaDB
        # tcp dport 5432 accept;  # PostgreSQL
        # tcp dport 27017 accept;  # MongoDB
        # tcp dport 6379 accept;  # Redis
        # tcp dport 1521 accept;  # Oracle
        # tcp dport 1433 accept;  # Microsoft SQL Server
        # tcp dport 9042 accept;  # Cassandra
        # tcp dport { 5044, 5601, 9200, 9300} accept;  # Elasticsearch, Kibana, Logstash

        # Allow ICMP (ping)
        icmp type { echo-request, destination-unreachable, time-exceeded } limit rate 1/second accept;
        icmp type { echo-request, destination-unreachable, time-exceeded } log prefix "WARNING - High ICMP Rate: " level warn drop;

        # Log dropped packets
        log prefix "nftables-Dropped: " level debug drop;
    }
}


#!/usr/sbin/nft -f

flush ruleset

table inet filter {
	chain input {
        type filter hook input priority filter; policy drop;

        iifname "lo" accept # Accept any localhost traffic
        ct state {established, related} accept # Accept traffic originated from us
        ct state invalid log prefix "WARNING - Invalid Packet: " level warn drop # Drop invalid packets

        meta l4proto ipv6-icmp accept # Accept ICMPv6
		meta l4proto icmp accept # Accept ICMP
		ip protocol igmp accept # Accept IGMP

        tcp dport ssh ct state new limit rate 3/minute burst 10 packets accept # Rate limiting for SSH connections

        tcp dport { http, https, 8008, 8080 } accept # Accept http/https traffic

        udp dport mdns ip6 daddr ff02::fb accept # Accept mDNS
		udp dport mdns ip daddr 224.0.0.251 accept # Accept mDNS

        udp sport bootpc udp dport bootps ip saddr 0.0.0.0 ip daddr 255.255.255.255 accept # Accept DHCPDISCOVER
	}
	chain forward {
		type filter hook forward priority filter; policy drop;
	}
	chain output {
		type filter hook output priority filter; policy accept;
	}
}





Workstation

/etc/nftables.conf

flush ruleset

table inet my_table {
	set LANv4 {
		type ipv4_addr
		flags interval

		elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 }
	}
	set LANv6 {
		type ipv6_addr
		flags interval

		elements = { fd00::/8, fe80::/10 }
	}

	chain my_input_lan {
		udp sport 1900 udp dport >= 1024 meta pkttype unicast limit rate 4/second burst 20 packets accept comment "Accept UPnP IGD port mapping reply"

		udp sport netbios-ns udp dport >= 1024 meta pkttype unicast accept comment "Accept Samba Workgroup browsing replies"

	}

	chain my_input {
		type filter hook input priority filter; policy drop;

		iif lo accept comment "Accept any localhost traffic"
		ct state invalid drop comment "Drop invalid connections"
		ct state established,related accept comment "Accept traffic originated from us"

		meta l4proto icmp icmp type echo-request limit rate over 10/second burst 4 packets drop # No ping floods
		meta l4proto ipv6-icmp icmpv6 type echo-request limit rate over 10/second burst 4 packets drop # No ping floods
		ip protocol igmp accept # Accept IGMP

		udp dport mdns ip6 daddr ff02::fb accept comment "Accept mDNS"
		udp dport mdns ip daddr 224.0.0.251 accept comment "Accept mDNS"

		ip6 saddr @LANv6 jump my_input_lan comment "Connections from private IP address ranges"
		ip saddr @LANv4 jump my_input_lan comment "Connections from private IP address ranges"

		counter comment "Count any other traffic"
	}

	chain my_forward {
		type filter hook forward priority filter; policy drop;
		# Drop everything forwarded to us. We do not forward. That is routers job.
	}

	chain my_output {
		type filter hook output priority filter; policy accept;
		# Accept every outbound connection
	}

}




Server

/etc/nftables.conf

flush ruleset

table inet my_table {
	set LANv4 {
		type ipv4_addr
		flags interval

		elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 }
	}
	set LANv6 {
		type ipv6_addr
		flags interval

		elements = { fd00::/8, fe80::/10 }
	}

	chain my_input_lan {
		meta l4proto { tcp, udp } th dport 2049 accept comment "Accept NFS"

		udp dport netbios-ns accept comment "Accept NetBIOS Name Service (nmbd)"
		udp dport netbios-dgm accept comment "Accept NetBIOS Datagram Service (nmbd)"
		tcp dport netbios-ssn accept comment "Accept NetBIOS Session Service (smbd)"
		tcp dport microsoft-ds accept comment "Accept Microsoft Directory Service (smbd)"

		udp sport { bootpc, 4011 } udp dport { bootps, 4011 } accept comment "Accept PXE"
		udp dport tftp accept comment "Accept TFTP"
	}

	chain my_input {
		type filter hook input priority filter; policy drop;

		iif lo accept comment "Accept any localhost traffic"
		ct state invalid drop comment "Drop invalid connections"
		ct state established,related accept comment "Accept traffic originated from us"

		meta l4proto ipv6-icmp accept comment "Accept ICMPv6"
		meta l4proto icmp accept comment "Accept ICMP"
		ip protocol igmp accept comment "Accept IGMP"

		udp dport mdns ip6 daddr ff02::fb accept comment "Accept mDNS"
		udp dport mdns ip daddr 224.0.0.251 accept comment "Accept mDNS"

		ip6 saddr @LANv6 jump my_input_lan comment "Connections from private IP address ranges"
		ip saddr @LANv4 jump my_input_lan comment "Connections from private IP address ranges"

		tcp dport ssh accept comment "Accept SSH on port 22"

		tcp dport ipp accept comment "Accept IPP/IPPS on port 631"

		tcp dport { http, https, 8008, 8080 } accept comment "Accept HTTP (ports 80, 443, 8008, 8080)"

		udp sport bootpc udp dport bootps ip saddr 0.0.0.0 ip daddr 255.255.255.255 accept comment "Accept DHCPDISCOVER (for DHCP-Proxy)"
	}

	chain my_forward {
		type filter hook forward priority filter; policy drop;
		# Drop everything forwarded to us. We do not forward. That is routers job.
	}

	chain my_output {
		type filter hook output priority filter; policy accept;
		# Accept every outbound connection
	}

}




Limit rate

table inet my_table {
	chain my_input {
		type filter hook input priority filter; policy drop;

		iif lo accept comment "Accept any localhost traffic"
		ct state invalid drop comment "Drop invalid connections"

		meta l4proto icmp icmp type echo-request limit rate over 10/second burst 4 packets drop comment "No ping floods"
		meta l4proto ipv6-icmp icmpv6 type echo-request limit rate over 10/second burst 4 packets drop comment "No ping floods"

		ct state established,related accept comment "Accept traffic originated from us"

		meta l4proto ipv6-icmp accept comment "Accept ICMPv6"
		meta l4proto icmp accept comment "Accept ICMP"
		ip protocol igmp accept comment "Accept IGMP"

		tcp dport ssh ct state new limit rate 15/minute accept comment "Avoid brute force on SSH"

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
