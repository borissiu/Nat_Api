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

configNatPool=$(cat << EOF
{
  "pool-list": [
    {
      "pool-name":"snat114",
      "start-address":"114.114.114.21",
      "end-address":"114.114.114.23",
      "netmask":"/24"
    },
    {
      "pool-name":"snat115a",
      "start-address":"115.115.115.21",
      "end-address":"115.115.115.23",
      "netmask":"/16"
    },
    {
      "pool-name":"snat115b",
      "start-address":"115.115.115.26",
      "end-address":"115.115.115.29",
      "netmask":"/16"
    }
  ]
}
EOF
)

configGlid=$(cat << EOF
{
  "glid-list": [
    {
      "num":5,
      "use-nat-pool":"snat115a"
    },
    {
      "num":6,
      "use-nat-pool":"snat115b"
    }
  ]
}
EOF
)

configClassList=$(cat << EOF
{
  "class-list-list": [
    {
      "name":"WiFi_Guest",
      "type":"ipv4",
      "ipv4-list": [
        {
          "ipv4addr":"10.10.0.5/32",
          "glid":5
        },
        {
          "ipv4addr":"10.10.0.6/32",
          "glid":6
        }
      ]
    }
  ]
}
EOF
)

configNatList=$(cat << EOF
{
  "class-list": {
    "name":"WiFi_Guest"
  }
}
EOF
)

if [ $statusCode -eq 200 ]
then
  token=$(cat $tmpFile | jq -r '.authresponse.signature')
  token="Authorization: A10 $token"

  curl -s -k -X PUT $device/axapi/v3/ip/nat/pool \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configNatPool"

  curl -s -k -X PUT $device/axapi/v3/glid \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configGlid"

  curl -s -k -X PUT $device/axapi/v3/class-list \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configClassList"

  curl -s -k -X PUT $device/axapi/v3/ip/nat/inside/source/class-list \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configNatList"


  curl -s -k POST $device/axapi/v3/logoff \
  -H "$token" > /dev/null
else
  echo "$device $statusCode - Please check IP and Credentials"
fi
