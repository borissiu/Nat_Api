# NAT API Demo - 01Sep22
1. Create 1:1 NAT (a few entries) by running ./api_nat_static_1.sh
2. Create 1:1 NAT (30000 entries) by running ./api_nat_range_1.sh
3. Create 1:Many PAT (access-list based) by running ./api_nat_accesslist_1.sh
4. Create 1:Maby PAT (class-list based) by running ./api_nat_classlist_1.sh
5. A10 Initial Config
6. A10 Config after steps 1, 2, 3, 4
7. Optional Setting

API Manual : https://acos.docs.a10networks.com/axapi/414gr1p6/ip_nat_inside_source_class_list.html

### 1. Create 1:1 NAT (a few entries) by running ./api_nat_static_1.sh
```
interface ve 114
  ip address 114.114.114.31 255.255.255.0
  ip nat outside
!
interface ve 115
  ip address 115.115.0.31 255.255.0.0
  ip nat outside
!
interface ve 192
  ip address 10.10.0.31 255.255.0.0
  ip nat inside
!
!
ip nat inside source static 10.10.0.10 114.114.114.10
!
ip nat inside source static 10.10.0.11 114.114.114.11
!
ip nat inside source static 10.10.0.15 114.114.114.15 disable
```

```
NAT_Device_31#rep 1 show session | inc Icmp
Icmp 10.10.0.10:22500  1.1.1.1  1.1.1.1  114.114.114.10:22500      1     1    NSe0f0r0  ST-NAT
Icmp 10.10.0.11:22516  1.1.1.1  1.1.1.1  114.114.114.11:22516      1     2    NSe0f0r0  ST-NAT
```

```
NAT_Device_31#show ip nat static-binding statistics
Source Address       Port Usage   Total Used   Total Freed
---------------------------------------------------------------------------
10.10.0.10           0            2            2
10.10.0.11           0            6            6
10.10.0.15           0            0            0
```

### 2. Create 1:1 NAT (30000 entries) by running ./api_nat_range_1.sh
```
ip nat range-list server 10.10.0.128 255.255.255.0 114.114.114.128 255.255.255.0 count 32
!
ip nat range-list IoT 10.10.115.128 255.255.0.0 115.115.115.128 255.255.0.0 count 30000
```

```
NAT_Device_31#rep 1 show session | inc Icmp
Icmp 10.10.115.128:22904  1.1.1.1  1.1.1.1  115.115.115.128:22904     1     5    NSe0f0r0  ST-NAT
Icmp 10.10.225.229:23023  1.1.1.1  1.1.1.1  115.115.225.229:23023     0     5    NSe0f0r0  ST-NAT
```

```
NAT_Device_31#show ip nat range-list
Total Static NAT range lists: 2
Name            Local Address/Mask           Global Address/Mask          Count VRID ACL
------------------------------------------------------------------------------------------------
server          10.10.0.128/24               114.114.114.128/24           32    0
IoT             10.10.115.128/16             115.115.115.128/16           30000 0
```

### 3. Create 1:Many PAT (access-list based) by running ./api_nat_accesslist_1.sh
```
ip access-list WiFi
  permit ip 10.10.0.0 0.0.0.7 any log
!
ip nat pool snat114 114.114.114.21 114.114.114.23 netmask /24
!
ip nat inside source list name WiFi pool snat114
```

```
NAT_Device_31#rep 1 show session | inc Icmp
Icmp 10.10.0.5:25885  1.1.1.1  1.1.1.1  114.114.114.21:2070       1     1    NSe0f0r0  NAT
Icmp 10.10.0.6:25952  1.1.1.1  1.1.1.1  114.114.114.21:2312       1     3    NSe0f0r0  NAT
```

```
NAT_Device_31#show ip nat pool statistics
Pool      Address                 Port Usage  Total Used  Total Freed Failed
----------------------------------------------------------------------------
snat114   114.114.114.21          0           49          49          0
          114.114.114.22          0           0           0
          114.114.114.23          0           0           0
snat115a  115.115.115.21          0           1           1           0
          115.115.115.22          0           0           0
          115.115.115.23          0           0           0
snat115b  115.115.115.26          0           5           5           0
          115.115.115.27          0           0           0
          115.115.115.28          0           0           0
          115.115.115.29          0           0           0
NAT_Device_31#
```

```
boris@Mac Nat_Api % ./api_stat_nat_pool_1.sh
{
  "pool-list": [
    {
      "stats" : {
        "Port-Usage": 0,
        "Total-Used": 49,
        "Total-Freed": 49,
        "Failed": 0
      },
      "a10-url":"/axapi/v3/ip/nat/pool/snat114/stats",
      "pool-name":"snat114"
    },
    {
      "stats" : {
        "Port-Usage": 0,
        "Total-Used": 1,
        "Total-Freed": 1,
        "Failed": 0
      },
      "a10-url":"/axapi/v3/ip/nat/pool/snat115a/stats",
      "pool-name":"snat115a"
    },
    {
      "stats" : {
        "Port-Usage": 0,
        "Total-Used": 5,
        "Total-Freed": 5,
        "Failed": 0
      },
      "a10-url":"/axapi/v3/ip/nat/pool/snat115b/stats",
      "pool-name":"snat115b"
    }
  ]
}
```

### 4. Create 1:Many PAT (class-list based) by running ./api_nat_classlist_1.sh
```
ip nat pool snat115a 115.115.115.21 115.115.115.23 netmask /16
!
ip nat pool snat115b 115.115.115.26 115.115.115.29 netmask /16
!
ip nat inside source class-list WiFi_Guest
!
glid 5
  use-nat-pool snat115a
!
glid 6
  use-nat-pool snat115b
!
class-list WiFi_Guest ipv4
  10.10.0.5/32 glid 5
  10.10.0.6/32 glid 6
```

```
NAT_Device_31#rep 1 show session | inc Icmp
Icmp 10.10.0.5:28377  1.1.1.1  1.1.1.1  115.115.115.21:2052       1     1    NSe0f0r0  NAT
Icmp 10.10.0.6:28396  1.1.1.1  1.1.1.1  115.115.115.26:2051       1     3    NSe0f0r0  NAT
```

### 5. A10 Initial Config
```
NAT_Device_31#show run
!Current configuration: 844 bytes
!Configuration last updated at 02:01:03 IST Fri Sep 2 2022
!Configuration last saved at 01:25:56 IST Fri Sep 2 2022
!64-bit Advanced Core OS (ACOS) version 4.1.4-GR1-P10, build 65 (Apr-24-2022,06:45)
!
authentication login privilege-mode local
!
!
system ve-mac-scheme system-mac
!
vlan 114
  untagged ethernet 1
  router-interface ve 114
!
vlan 115
  untagged ethernet 2
  router-interface ve 115
!
vlan 192
  untagged ethernet 6
  router-interface ve 192
!
partition isp_router id 1 application-type adc
!
hostname NAT_Device_31
!
!
interface management
  ip address 192.168.2.31 255.255.255.0
  ip default-gateway 192.168.2.1
!
interface ethernet 1
  enable
!
interface ethernet 2
  enable
!
interface ethernet 3
  enable
!
interface ethernet 4
  enable
!
interface ethernet 5
  enable
!
interface ethernet 6
  enable
!
interface ethernet 7
!
interface ethernet 8
!
interface ethernet 9
!
interface ethernet 10
!
interface ve 114
  ip address 114.114.114.31 255.255.255.0
!
interface ve 115
  ip address 115.115.0.31 255.255.0.0
!
interface ve 192
  ip address 10.10.0.31 255.255.0.0
!
!
ip route 1.1.1.1 /32 114.114.114.32
!
ip route 2.2.2.2 /32 115.115.115.32
!
!
sflow setting local-collection
!
sflow collector ip 127.0.0.1 6343
!
!
end
```

### 6. A10 Config after steps 1, 2, 3, 4
```
NAT_Device_31#show run
!Current configuration: 1682 bytes
!Configuration last updated at 02:12:15 IST Fri Sep 2 2022
!Configuration last saved at 01:25:56 IST Fri Sep 2 2022
!64-bit Advanced Core OS (ACOS) version 4.1.4-GR1-P10, build 65 (Apr-24-2022,06:45)
!
authentication login privilege-mode local
!
!
system ve-mac-scheme system-mac
!
ip access-list WiFi
  permit ip 10.10.0.0 0.0.0.7 any log
!
vlan 114
  untagged ethernet 1
  router-interface ve 114
!
vlan 115
  untagged ethernet 2
  router-interface ve 115
!
vlan 192
  untagged ethernet 6
  router-interface ve 192
!
partition isp_router id 1 application-type adc
!
hostname NAT_Device_31
!
!
interface management
  ip address 192.168.2.31 255.255.255.0
  ip default-gateway 192.168.2.1
!
interface ethernet 1
  enable
!
interface ethernet 2
  enable
!
interface ethernet 3
  enable
!
interface ethernet 4
  enable
!
interface ethernet 5
  enable
!
interface ethernet 6
  enable
!
interface ethernet 7
!
interface ethernet 8
!
interface ethernet 9
!
interface ethernet 10
!
interface ve 114
  ip address 114.114.114.31 255.255.255.0
  ip nat outside
!
interface ve 115
  ip address 115.115.0.31 255.255.0.0
  ip nat outside
!
interface ve 192
  ip address 10.10.0.31 255.255.0.0
  ip nat inside
!
!
ip nat pool snat114 114.114.114.21 114.114.114.23 netmask /24
!
ip nat pool snat115a 115.115.115.21 115.115.115.23 netmask /16
!
ip nat pool snat115b 115.115.115.26 115.115.115.29 netmask /16
!
ip nat inside source class-list WiFi_Guest
!
ip nat inside source list name WiFi pool snat114
!
ip nat inside source static 10.10.0.10 114.114.114.10
!
ip nat inside source static 10.10.0.11 114.114.114.11
!
ip nat inside source static 10.10.0.15 114.114.114.15 disable
!
ip nat range-list server 10.10.0.128 255.255.255.0 114.114.114.128 255.255.255.0 count 32
!
ip nat range-list IoT 10.10.115.128 255.255.0.0 115.115.115.128 255.255.0.0 count 30000
!
glid 5
  use-nat-pool snat115a
!
glid 6
  use-nat-pool snat115b
!
class-list WiFi_Guest ipv4
  10.10.0.5/32 glid 5
  10.10.0.6/32 glid 6
!
ip route 1.1.1.1 /32 114.114.114.32
!
ip route 2.2.2.2 /32 115.115.115.32
!
!
sflow setting local-collection
!
sflow collector ip 127.0.0.1 6343
!
!
end
!Current config commit point for partition 0 is 0 & config mode is classical-mode
NAT_Device_31#
```

### 7. Optional Setting
```
ip nat translation service-timeout tcp 8080 age 7200 !(default : follow tcp-timeout setting)
!
ip nat-global reset-idle-tcp-conn !(default : off)
!
ip nat translation tcp-timeout 600 !(default : 300)
ip nat translation udp-timeout 600 !(default : 300)
ip nat translation ignore-tcp-msl  !(default : off)
!
ip nat alg pptp enable !(default : off)
!
!!! For CGN only?
ip nat template logging nat_logging
  log port-mappings creation
  include-destination
  include-rip-rport
  facility syslog
  severity informational
  service-group sg-syslog_udp514
```

```
NAT_Device_31#show ip nat alg pptp statistics
Statistics for PPTP NAT ALG:
-----------------------------
Calls In Progress:               0
Call Creation Failure:           0
Truncated PNS Message:           0
Truncated PAC Message:           0
Mismatched PNS Call ID:          0
Mismatched PAC Call ID:          0
Retransmitted PAC Message:       0
Truncated GRE Packets:           0
Unknown GRE Packets:             0
No Matching GRE Session:         0
NAT_Device_31#
```