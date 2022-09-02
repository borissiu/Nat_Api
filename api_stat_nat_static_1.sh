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

if [ $statusCode -eq 200 ]
then
  token=$(cat $tmpFile | jq -r '.authresponse.signature')
  token="Authorization: A10 $token"

### No API-EndPoint for show ip nat static-binding statistics
  curl -I -k $device/axapi/v3/ip/nat/inside/source/static-list/10.10.0.10+114.114.114.10/stats \
  -H "Content-Type:application/json" \
  -H "$token"

  curl -s -k POST $device/axapi/v3/logoff \
  -H "$token" > /dev/null
else
  echo "$device $statusCode - Please check IP and Credentials"
fi
