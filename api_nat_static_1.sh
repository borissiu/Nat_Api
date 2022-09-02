#!/bin/zsh
###
### ./api_demo_nat_static.sh
###

device="https://192.168.2.31"
token="" data="" statusCode="" tmpFile="/Users/boris/Data/Api/Nat_Api/auth.json"

### API EndPoint Logon = /axapi/v3/auth
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

configVe114=$(cat << EOF
{
  "ve": {
    "ifnum":114,
    "ip": {
      "address-list": [
        {
          "ipv4-address":"114.114.114.31",
          "ipv4-netmask":"255.255.255.0"
        }
      ],
      "outside":1
    }
  }
}
EOF
)

configVe115=$(cat << EOF
{
  "ve": {
    "ifnum":115,
    "ip": {
      "address-list": [
        {
          "ipv4-address":"115.115.0.31",
          "ipv4-netmask":"255.255.0.0"
        }
      ],
      "outside":1
    }
  }
}
EOF
)

configVe192=$(cat << EOF
{
  "ve": {
    "ifnum":192,
    "ip": {
      "address-list": [
        {
          "ipv4-address":"10.10.0.31",
          "ipv4-netmask":"255.255.0.0"
        }
      ],
      "inside":1
    }
  }
}
EOF
)

configNatStatic=$(cat << EOF
{
  "static-list": [
    {
      "src-address":"10.10.0.10",
      "nat-address":"114.114.114.10"
    },
    {
      "src-address":"10.10.0.11",
      "nat-address":"114.114.114.11"
    },
    {
      "src-address":"10.10.0.15",
      "nat-address":"114.114.114.15",
      "action":"disable"
    }
  ]
}
EOF
)

if [ $statusCode -eq 200 ]
then
  token=$(cat $tmpFile | jq -r '.authresponse.signature')
  token="Authorization: A10 $token"

  # Check API-EndPoint Schema, e.g. /axapi/v3/interface/ve/114/schema
  # curl -s -k $device/axapi/v3/interface/ve/114/schema \
  # -H "Content-Type:application/json" \
  # -H "$token" \
  

  ### API EndPoint Logon = /axapi/v3/interface/ve/{name}
  curl -s -k -X PUT $device/axapi/v3/interface/ve/114 \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configVe114"

  curl -s -k -X PUT $device/axapi/v3/interface/ve/115 \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configVe115"

  curl -s -k -X PUT $device/axapi/v3/interface/ve/192 \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configVe192"

  ### API EndPoint Logon = /axapi/v3/ip/nat/inside/source/static
  curl -s -k -X POST $device/axapi/v3/ip/nat/inside/source/static \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configNatStatic"

  
  ### API EndPoint Logon = /axapi/v3/logoff
  curl -s -k POST $device/axapi/v3/logoff \
  -H "$token" > /dev/null
else
  echo "$device $statusCode - Please check IP and Credentials"
fi
