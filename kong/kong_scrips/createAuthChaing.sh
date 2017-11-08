# Creates jwt oauth2 key-auth ACL terminate authentication scheme

set -e

# Create setup: API and consumer
curl -i -X POST \
   --url http://localhost:8001/apis \
   --data 'name=chain' \
   --data 'hosts=mock.dev' \
   --data 'upstream_url=http://mockbin.org'

# Create consumer
curl -i -X POST \
   --url http://localhost:8001/consumers \
   --data 'custom_id=chain-user'

# Create plugins
# Create JWT for user context
curl -i -X POST \
   --url http://localhost:8001/apis/chain/plugins \
   --data 'name=jwt'

# Create Oauth2 for user grants for application with scopes
#curl -i -X POST \
#   --url http://localhost:8001/apis/chain/plugins  \

# Create Key-auth plugin for application trust
curl -i -X POST \
   --url http://localhost:8001/consumers/chain-user/key-auth  \
   --data 'key=youshallpass'

# Create ACL plugin to application to use specific service 
#curl -i -X POST \
#   --url http://localhost:8001/apis/chain/plugins  \

# create terminate plugin for anonymous access
#curl -i -X POST \
#   --url http://localhost:8001/apis/chain/plugins  \
