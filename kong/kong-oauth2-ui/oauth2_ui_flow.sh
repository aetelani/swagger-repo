
http :8001/apis name=cats uris=/cats upstream_url=http://mockbin.org/request

echo Provision key
http :8001/apis/cats/plugins/ \
	name=oauth2 \
	config.scopes="email, address, phone" \
	config.mandatory_scope=true \
	config.enable_authorization_code=true | jq ".config.provision_key" 
echo "Copy paste^\n"

http :8001/consumers/ \
	username=thefosk

echo Client ID
http :8001/consumers/thefosk/oauth2/ \
	name="Hello World App" \
    redirect_uri=http://mockbin.org/ | jq ".client_id"
echo "Copy to browser ^\n"

echo enter provision key
read PROVISION_KEY
export PROVISION_KEY

export KONG_ADMIN="http://127.0.0.1:8001"
echo Kong Admin $KONG_ADMIN

export KONG_API="https://127.0.0.1:8443"
echo Kong API $KONG_API

export API_PATH="/cats"
echo Kong API path $API_PATH

export SCOPES="{ \
  \"email\": \"Grant permissions to read your email address\", \
  \"address\": \"Grant permissions to read your address information\", \
  \"phone\": \"Grant permissions to read your mobile phone number\" \
}"
echo Oauth2 Scope $SCOPES

export LISTEN_PORT=3301
echo Node listening port $LISTEN_PORT

echo Ready steady Go...
node app.js

# http://127.0.0.1:3301/authorize?response_type=code&scope=email%20address%20phone&client_id=3iQbFYROkn6nupu2Q2GfBEo2SUCZxU9C
# shouls be redirect to http://mockbin.org/request?code=ad286cf6694d40aac06eff2797b7208d
