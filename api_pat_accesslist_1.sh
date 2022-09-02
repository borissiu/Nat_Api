#!/bin/zsh
###
### API NAT Demo - 01Sep22
###

device="https://192.168.2.31"
token="" data="" statusCode="" tmpFile="/Users/boris/Data/Api/Nat_Api/auth.json"

statusCode=$(
curl --write-out "%{http_code}\n" --connect-timeout 1 -s -k $device/axapi/v3/auth --output $tmpFile \
-H "Content-Type:application/json" \
-d '{
  "credentials": {
  "username": "admin",
  "password": "a10"
  }
}'
)


configAccessList=$(cat << EOF
{
  "access-list-list": [
    {
      "name":"WiFi",
      "rules": [
        {
          "seq-num":24,
          "action":"permit",
          "ip":1,
          "src-subnet":"10.10.0.0",
          "src-mask":"0.0.0.7",
          "dst-any":1,
          "acl-log":1
        }
      ]
    }
  ]
}
EOF
)

configNatPool=$(cat << EOF
{
  "pool-list": [
    {
      "pool-name":"snat114",
      "start-address":"114.114.114.21",
      "end-address":"114.114.114.23",
      "netmask":"/24"
    }
  ]
}
EOF
)

configNatList=$(cat << EOF
{
  "acl-name-list-list": [
    {
      "name":"WiFi",
      "pool":"snat114"
    }
  ]
}
EOF
)

if [ $statusCode -eq 200 ]
then
  token=$(cat $tmpFile | jq -r '.authresponse.signature')
  token="Authorization: A10 $token"


  curl -s -k -X PUT $device/axapi/v3/ip/access-list \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configAccessList"

  curl -s -k -X PUT $device/axapi/v3/ip/nat/pool \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configNatPool"

  curl -s -k -X PUT $device/axapi/v3/ip/nat/inside/source/list/acl-name-list \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configNatList"


  curl -s -k PUT $device/axapi/v3/logoff \
  -H "$token" > /dev/null
else
  echo "$device $statusCode - Please check IP and Credentials"
fi
