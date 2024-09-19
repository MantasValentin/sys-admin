dnf install bind -y

# add logging 
logging {
  category notify { zone_transfer_log; };
  category xfer-in { zone_transfer_log; };
  category xfer-out { zone_transfer_log; };
  channel zone_transfer_log {
    file "/var/named/log/transfer.log" versions 10 size 50m;
    print-time yes;
    print-category yes;
    print-severity yes;
    severity info;
  };
};

mkdir /var/named/log/
touch /var/named/log/transfer.log
chown named:named /var/named/log/ -R

# or dnstap
/etc/named.conf

options {
dnstap { all; }; # Configure filter
dnstap-output file "/var/named/data/dnstap.bin";
};

# and read it by using 
dnstap-read /var/named/data/dnsta.bin

# Change /etc/resolv.conf
nameserver 127.0.0.1

# restart dns server
systemctl restart named

# Creating zones

/etc/named.conf

zone "example.com" {
type master;
file "example.com.zone";
allow-query { any; };
allow-transfer { none; };
};

touch /var/named/example.com.zone
chown root:named /var/named/example.com.zone
chmod 640 /var/named/example.com.zone

/var/named/example.com.zone

$TTL 8h
@ IN SOA ns1.example.com. hostmaster.example.com. (
2022070601 ; serial number
1d ; refresh period
3h ; retry period
3d ; expire time
3h ) ; minimum TTL
IN NS ns1.example.com.
IN MX 10 mail.example.com.
www IN A 192.0.2.30
www IN AAAA 2001:db8:1::30
ns1 IN A 192.0.2.1
ns1 IN AAAA 2001:db8:1::1
mail IN A 192.0.2.20
mail IN AAAA 2001:db8:1::20

systemctl reload named