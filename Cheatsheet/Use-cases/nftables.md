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
