#!/usr/bin/env bash

echo "###################################################"
echo "Build local AWS Lambda's execution environment"
echo "###################################################"

sam build

echo "###################################################"
echo "Get token from Keycloak client"
echo "###################################################"
GRANT_TYPE="grant_type=client_credentials"
CLIENT="client_id=server-to-server&client_secret=xxxxxxxxxxxx"
TOKEN_URL="http://ops-keycloak.softcomweb.info:8080/auth/realms/si/protocol/openid-connect/token"

ACCESS_TOKEN=$(curl --data "${GRANT_TYPE}&${CLIENT}" ${TOKEN_URL} | jq -r .access_token)
echo "Access token: ${ACCESS_TOKEN}"
echo

echo "###################################################"
echo "Invoke auth lambda"
echo "###################################################"
cat <<EOF | sam local invoke "AuthFunction" --event -
{
    "authorizationToken": "Bearer ${ACCESS_TOKEN}",
    "methodArn": "any-arn"
}
EOF