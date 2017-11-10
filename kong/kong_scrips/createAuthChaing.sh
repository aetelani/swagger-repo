# Creates jwt oauth2 key-auth ACL terminate authentication scheme
# uses httpie and jq tools

set -e

#KONG_ADMIN=http://<KONG_REMOTE_AMDIN>:8001
KONG_LOCAL=:8001
# Setup localhost loopback to Kong admin
#http $KONG_LOCAL name=loopback hosts=127.0.0.1 upstream_host=$KONG_ADMIN

# Create setup: API and consumer
http :8001/apis \
   name=chain \
   hosts=mock.dev \
   upstream_url=http://mockbin.org

# Create consumer
http -p HBhb :8001/consumers \
   username=chain-user

http -p HBhb :8001/consumers/chain-user/acls \
   group=chain-users

# Create plugins
# Create JWT for user context
http :8001/apis/chain/plugins \
   name=jwt

# Create Oauth2 for user grants for application with scopes
http :8001/apis/chain/plugins \
   name=oauth2 \
   config.enable_authorization_code=true \
   config.scopes=organization \
   config.mandatory_scope=true

# Create Key-auth plugin for application trust
http :8001/consumers/chain-user/key-auth  \
   key=youshallpass

# Create ACL plugin to application to use specific service. Whitelist chain-users only all else are blacklisted
http :8001/apis/chain/plugins  \
    name=acl \
    config.whitelist=chain-user
    

# create terminate plugin for anonymous access
http :8001/apis/chain/plugins \
    name=request-termination \
    config.status_code=403 \
    config.message=Hasta\ la\ vista

