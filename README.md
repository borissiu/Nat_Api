# Nat_Api
1. Create 1:1 NAT (a few entries) by running ./api_nat_static_1.sh
2. Create 1:1 NAT (30000 entries) by running ./api_nat_range_1.sh
3. Create 1:Many PAT (access-list based) by running ./api_nat_accesslist_1.sh
4. Create 1:Maby PAT (class-list based) by running ./api_nat_classlist_1.sh
5. A10 Initial Config

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

### 2. Create 1:1 NAT (30000 entries) by running ./api_nat_range_1.sh
```
ip nat range-list server 10.10.0.128 255.255.255.0 114.114.114.128 255.255.255.0 count 32
!
ip nat range-list IoT 10.10.115.128 255.255.0.0 115.115.115.128 255.255.0.0 count 30000
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

### 4. Create 1:Maby PAT (class-list based) by running ./api_nat_classlist_1.sh
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