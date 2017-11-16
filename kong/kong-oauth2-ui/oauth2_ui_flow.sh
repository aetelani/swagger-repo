#!/bin/bash

http :8001/apis name=poc uris=/poc upstream_url=http://mockbin.org/request

cat <<EOF > env
export PROVISION_KEY=PoC
export CLIENT_ID=PoC
export CLIENT_SECRET=passmein
export KONG_ADMIN="http://127.0.0.1:8001"
export KONG_API="https://127.0.0.1:8443"
export API_PATH="/poc"
export LISTEN_PORT=3301
export SCOPES="{ \
  \"email\": \"Grant permissions to read your email address\", \
  \"address\": \"Grant permissions to read your address information\", \
  \"phone\": \"Grant permissions to read your mobile phone number\" \
}"
export REDIRECT_ADDRESS="http://localhost:\${LISTEN_PORT}/access-token/"
EOF

. ./env

http :8001/apis/poc/plugins/ \
	name=oauth2 \
	config.scopes="email, address, phone" \
	config.mandatory_scope=true \
	config.provision_key=$PROVISION_KEY \
	config.enable_authorization_code=true

http :8001/consumers/ \
	username=poc

http :8001/consumers/poc/oauth2/ \
	name=$CLIENT_ID \
	client_secret=$CLIENT_SECRET \
	client_id=$CLIENT_ID \
    redirect_uri=$REDIRECT_ADDRESS
echo Copy client id to $CLIENT_ID to browser


export PROVISION_KEY
echo "Provision key: $PROVISION_KEY"

export KONG_ADMIN="http://127.0.0.1:8001"
echo Kong Admin $KONG_ADMIN

export KONG_API="https://127.0.0.1:8443"
echo Kong API $KONG_API

export API_PATH="/poc"
echo Kong API path $API_PATH

export SCOPES

export LISTEN_PORT
echo Node listening port $LISTEN_PORT

# Shortcut to AuthZ page
echo "lynx \"localhost:3301/authorize?response_type=code&scope=email%20address%20phone&client_id=$CLIENT_ID\"" > gotoAuthzPage.sh

#export CODE=$(http  http://mockbin.org/request?code=3MDW3e6gEe1ZLXLjHGiwemeYfoMELCBk | jq -r ".queryString.code")
# Get access token with tbd exported $CODE
echo "http -v --verify=no https://127.0.0.1:8443/poc/oauth2/token grant_type=authorization_code client_id=$CLIENT_ID client_secret=$CLIENT_SECRET redirect_uri=$REDIRECT_ADDRESS code=\$CODE" > getRefreshToken.sh

echo Ready steady Go...
echo ". ./env" > startApp.sh
echo "node app.js\n" >> startApp.sh

# http :3301/authorize response_type==code scope==email%20address%20phone client_id==$CLIENT_ID
# shouls be redirect to http://mockbin.org/request?code=$CLIENT_ID
