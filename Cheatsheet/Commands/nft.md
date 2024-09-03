## Basic Syntax
nft [options] <command> [family] <table> [chain] [rule]

- Options: Various command-line options
- Command: The action to perform (add, delete, list, etc.)
- Family: The protocol family (ip, ip6, inet, arp, bridge, netdev)
- Table: The table to operate on
- Chain: The chain within the table
- Rule: The rule specification

## Tables

### Create a table
nft add table [family] <table-name>

### Delete a table
nft delete table [family] <table-name>

### Flush a table 
nft flush table [family] <table-name>

### List table
nft list table [family] <table-name>

### Check handle
sudo nft -a list table [family] <table-name>


## Chains

### Create a chain
nft add chain [family] <table-name> <chain-name> '{ type [type] hook [hook] priority [priority] \; policy [policy] \; }'

- type: filter, route, nat
- hook: prerouting, input, forward, output, postrouting
- priority: integer value (lower value = higher priority)
- policy: accept, drop, queue, continue, return

### Delete a chain
nft delete chain [family] <table-name> <chain-name>

### Edit a chain
nft chain [family] <table-name> <chain-name> '{ type [type] hook [hook] priority [priority] \; policy [policy]; }'

### Flush a chain 
nft flush chain [family] <table-name> <chain-name>

### List chain
nft list chain [family] <table-name> <chain-name>

### Check handle
sudo nft -a list chain [family] <table-name> <chain-name>

## Rules

- action: accept, drop, queue, continue, return, jump <chain-name>, goto <chain-name>

### Add a rule
nft add rule [family] <table-name> <chain-name> <match-criteria> <action>

### Delete a rule
nft delete rule [family] <table-name> <chain-name> handle <handle-number>

### Insert a rule
nft insert rule [family] <table-name> <chain-name> position <position-number> <match-criteria> <action>

### Replace a rule
nft replace rule [family] <table-name> <chain-name> handle <handle-number> <new-rule>

### List rules
nft list ruleset

## Sets

### Create a set
nft add set [family] <table-name> <set-name> { type <type> \; }

### Add elements to a set
nft add element [family] <table-name> <set-name> { <element1>, <element2>, ... }

### Delete elements from a set
nft delete element [family] <table-name> <set-name> { <element1>, <element2>, ... }

## Mappings

### Create a map
nft add map [family] <table-name> <map-name> { type <key-type> : <data-type> \; }

### Add elements to a map
nft add element [family] <table-name> <map-name> { <key1> : <value1>, <key2> : <value2>, ... }

## Stateful Objects

### Create a counter
nft add counter [family] <table-name> <counter-name>

### Create a quota
nft add quota [family] <table-name> <quota-name> { <bytes> <direction> }

### Create a limit
nft add limit [family] <table-name> <limit-name> { rate <rate> /second }

## Intervals

### Create an interval set
nft add set [family] <table-name> <set-name> { type <type> \; flags interval \; }

### Add interval elements
nft add element [family] <table-name> <set-name> { <start>-<end> }

## Flowtables

### Create a flowtable
nft add flowtable [family] <table-name> <flowtable-name> { hook <hook> priority <priority> \; devices = { <dev1>, <dev2>, ... } \; }



meta:
  oif <output interface INDEX>
  iif <input interface INDEX>
  oifname <output interface NAME>
  iifname <input interface NAME>

icmp:
  type <icmp type>

icmpv6:
  type <icmpv6 type>

ip:
  protocol <protocol>
  daddr <destination address>
  saddr <source address>

ip6:
  daddr <destination address>
  saddr <source address>

tcp:
  dport <destination port>
  sport <source port>

udp:
  dport <destination port>
  sport <source port>

sctp:
  dport <destination port>
  sport <source port>

ct:
  state <new | established | related | invalid>