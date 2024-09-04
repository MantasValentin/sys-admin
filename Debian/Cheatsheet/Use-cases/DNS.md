
/etc/bind/named.conf.local

zone "example.com" {
	type master;
	file "/etc/bind/db.example.com";
};


/etc/bind/db.example.com 

$TTL 604800
@   IN  SOA ns1.example.com. admin.example.com. (
       2023090401        ; Serial YYYYMMDDNN
           604800        ; Refresh
            86400        ; Retry
          2419200        ; Expire
           604800 )      ; Negative Cache TTL

@   IN  NS  ns1.example.com.
ns1 IN  A   192.168.0.215
@ IN  A   192.168.0.232
