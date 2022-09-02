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


configRangeList=$(cat << EOF
{
  "range-list-list": [
    {
      "name":"server",
      "local-start-ipv4-addr":"10.10.0.128",
      "local-netmaskv4":"255.255.255.0",
      "global-start-ipv4-addr":"114.114.114.128",
      "global-netmaskv4":"255.255.255.0",
      "v4-count":32
    },
    {
      "name":"IoT",
      "local-start-ipv4-addr":"10.10.115.128",
      "local-netmaskv4":"255.255.0.0",
      "global-start-ipv4-addr":"115.115.115.128",
      "global-netmaskv4":"255.255.0.0",
      "v4-count":30000
    }
  ]
}
EOF
)

if [ $statusCode -eq 200 ]
then
  token=$(cat $tmpFile | jq -r '.authresponse.signature')
  token="Authorization: A10 $token"


  curl -s -k -X PUT $device/axapi/v3/ip/nat/range-list \
  -H "Content-Type:application/json" \
  -H "$token" \
  -d "$configRangeList"


  curl -s -k POST $device/axapi/v3/logoff \
  -H "$token" > /dev/null
else
  echo "$device $statusCode - Please check IP and Credentials"
fi
