#!/bin/bash

# Mocking Three legged OAUTH2 flow

cat <<EOF > env
export KONGIP=127.0.0.1
export CONSUMER=poc
export PROVISION_KEY=PoC
export CLIENT_ID=PoC
export CLIENT_SECRET=passmein
export KONG_ADMIN="http://\${KONGIP}:8001"
export KONG_API="https://\${KONGIP}:8443"
export API_PATH="/poc"
export LISTEN_PORT=3301
export SCOPES="{ \
  \"email\": \"Grant permissions to read your email address\", \
  \"address\": \"Grant permissions to read your address information\", \
  \"phone\": \"Grant permissions to read your mobile phone number\" \
}"
export REDIRECT_ADDRESS="http://\${KONGIP}:\${LISTEN_PORT}/access-token/"
EOF

. ./env

http :8001/apis name=poc uris=${API_PATH} upstream_url=http://mockbin.org/request

http :8001/apis${API_PATH}/plugins/ \
	name=oauth2 \
	config.scopes="email, address, phone" \
	config.mandatory_scope=true \
	config.provision_key=${PROVISION_KEY} \
	config.enable_authorization_code=true # Three legged authentication

http :8001/consumers/ \
	username=${CONSUMER}

http :8001/consumers/${CONSUMER}/oauth2/ \
	name=${CLIENT_ID} \
	client_secret=${CLIENT_SECRET} \
	client_id=${CLIENT_ID} \
    redirect_uri=${REDIRECT_ADDRESS}

# Shortcut to AuthZ page
echo "lynx \"${KONGIP}:${LISTEN_PORT}/authorize?response_type=code&scope=email%20address%20phone&client_id=${CLIENT_ID}\"" > gotoAuthzPage.sh

# Get access token with tbd exported $CODE
echo "http -v --verify=no https://127.0.0.1:8443/poc/oauth2/token grant_type=authorization_code client_id=$CLIENT_ID client_secret=$CLIENT_SECRET redirect_uri=$REDIRECT_ADDRESS code=\$CODE" > getRefreshToken.sh

echo Ready steady Go... by sh startApp.sh
echo ". ./env" > startApp.sh
echo "node app.js" >> startApp.sh
