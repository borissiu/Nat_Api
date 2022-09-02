# Nat_Api
1. A10 Initial Config
2. Create 1:1 NAT (a few entries) by running ./api_nat_static_1.sh
3. Create 1:1 NAT (30000 entries) by running ./api_nat_range_1.sh
4. Create 1:Many PAT (access-list based) by running ./api_nat_accesslist_1.sh
5. Create 1:Maby PAT (class-list based) by running ./api_nat_classlist_1.sh

### A10 Initial Config
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

