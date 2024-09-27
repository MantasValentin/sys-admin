dnf install dhcp-server -y

/etc/dhcp/dhcpd.conf
/etc/dhcp/dhcpd6.conf

# Global
option domain-name "example.com";
default-lease-time 86400;

# Local
subnet 192.0.2.0 netmask 255.255.255.0 {
range 192.0.2.20 192.0.2.100;
option domain-name-servers 192.0.2.1;
option routers 192.0.2.1;
option broadcast-address 192.0.2.255;
max-lease-time 172800;
}

# Static

host server.example.com {
hardware ethernet 52:54:00:72:2f:6e;
fixed-address 192.0.2.130;
}