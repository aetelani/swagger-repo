
http :8001/apis name=poc uris=/poc upstream_url=http://mockbin.org/request

PROVISION_KEY=PoC
http :8001/apis/poc/plugins/ \
	name=oauth2 \
	config.scopes="email, address, phone" \
	config.mandatory_scope=true \
	config.provision_key=$PROVISION_KEY \
	config.enable_authorization_code=true

http :8001/consumers/ \
	username=poc

CLIENT_ID=PoC
CLIENT_SECRET=passmein
http :8001/consumers/poc/oauth2/ \
	name=$CLIENT_ID \
	client_secret=$CLIENT_SECRET \
	client_id=$CLIENT_ID \
    redirect_uri=http://mockbin.org/request
echo Copy client id to $CLIENT_ID to browser


export PROVISION_KEY
echo "Provision key: $PROVISION_KEY"

export KONG_ADMIN="http://127.0.0.1:8001"
echo Kong Admin $KONG_ADMIN

export KONG_API="https://127.0.0.1:8443"
echo Kong API $KONG_API

export API_PATH="/poc"
echo Kong API path $API_PATH

export SCOPES="{ \
  \"email\": \"Grant permissions to read your email address\", \
  \"address\": \"Grant permissions to read your address information\", \
  \"phone\": \"Grant permissions to read your mobile phone number\" \
}"
echo Oauth2 Scope $SCOPES

export LISTEN_PORT=3301
echo Node listening port $LISTEN_PORT

# Shortcut to AuthZ page
echo "firefox \"localhost:3301/authorize?response_type=code&scope=email%20address%20phone&client_id=$CLIENT_ID\"" > gotoAuthzPage.sh

# Get access token with tbd exported $CODE
echo "http -v --verify=no https://127.0.0.1:8443/oauth2/token Host:mock.dev grant_type=authorization_code client_id=$CLIENT_ID client_secret=$CLIENT_SECRET redirect_uri=http://mockbin.org/request code=\$CODE" > getRefreshToken.sh

echo Ready steady Go...
node app.js

# http :3301/authorize response_type==code scope==email%20address%20phone client_id==$CLIENT_ID
# shouls be redirect to http://mockbin.org/request?code=$CLIENT_ID
