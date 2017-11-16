#!/bin/bash

# Mocking client OAUTH2 flow

cat <<EOF > env
export KONGIP=kong
export CONSUMER=poc
export PROVISION_KEY=PoC
export CLIENT_ID=PoC
export CLIENT_SECRET=passmein
export KONG_ADMIN="http://\${KONGIP}:8001"
export KONG_API="https://\${KONGIP}:8443"
export API_PATH="/poc"
export GRANT_TYPE=client_credentials
export LISTEN_PORT=3301
export REDIRECT_ADDRESS="http://\${KONGIP}:\${LISTEN_PORT}/client-flow/"

# not used
export SCOPES="{ \
  \"email\": \"Grant permissions to read your email address\", \
  \"address\": \"Grant permissions to read your address information\", \
  \"phone\": \"Grant permissions to read your mobile phone number\" \
}"
EOF

. ./env

http :8001/apis name=poc uris=${API_PATH} upstream_url=${REDIRECT_ADDRESS}

http :8001/apis${API_PATH}/plugins/ \
	name=oauth2 \
	config.scopes="email, address, phone" \
	config.mandatory_scope=true \
	config.provision_key=${PROVISION_KEY} \
	config.enable_${GRANT_TYPE}=true # client_credentials

http :8001/consumers/ \
	username=${CONSUMER}

http :8001/consumers/${CONSUMER}/oauth2/ \
	name=${CLIENT_ID} \
	client_secret=${CLIENT_SECRET} \
	client_id=${CLIENT_ID} \
    redirect_uri=${REDIRECT_ADDRESS}

# Get access token with client OAUTH2 flow
echo "http --verify=no ${KONG_API}/poc/oauth2/token grant_type=$GRANT_TYPE scope=\"email address phone\" client_id=$CLIENT_ID client_secret=$CLIENT_SECRET redirect_uri=$REDIRECT_ADDRESS" > getClientFlowTokens.sh

# Fetch access token to for test
echo "export BEARER_TOKEN=$(sh getClientFlowTokens.sh  | jq -r ".access_token")" >> env

# Test Connection with Access Token.  Uses httpie token plugin
echo ". ./env; http --verify=no --auth-type=token --auth=\"Bearer:\${BEARER_TOKEN}\" \${KONG_API}\${API_PATH}" > testEndPoint.sh

echo Ready steady Go... by sh startApp.sh
echo ". ./env" > startApp.sh
echo "node app.js" >> startApp.sh
