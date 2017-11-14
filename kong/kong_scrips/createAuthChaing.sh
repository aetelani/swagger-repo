#!/bin/bash -x

# Creates jwt oauth2 key-auth ACL terminate authentication scheme
# uses httpie

set -e

#KONG_ADMIN=http://<KONG_REMOTE_AMDIN>:8001
KONG_LOCAL=:8001
# Setup localhost loopback to Kong admin
#http $KONG_LOCAL name=loopback hosts=127.0.0.1 upstream_host=$KONG_ADMIN

echo Create setup: API and consumer
http -v :8001/apis \
   name=chain \
   hosts=mock.dev \
   upstream_url=http://mockbin.org

echo Create consumer
http -v :8001/consumers \
   username=chain-user

echo Add group to consumer
http -v :8001/consumers/chain-user/acls \
   group=chain-group
   
echo Create Key-auth plugin to consumer
http -v :8001/consumers/chain-user/key-auth  \
   key=youshallpass

echo Create Oauth2 credentials to consumer
http :8001/consumers/chain-user/oauth2 \
    "name=Chain%20Application" \
    "client_id=chain-id" \
    "client_secret=chain-secret" \
    "redirect_uri=http://mockbin.org"

# lets wait for a couple sec to flush
sleep 5

##### Create plugins
echo Create JWT for user context
http -v post :8001/consumers/chain-user/jwt \
   Content-Type:application/x-www-form-urlencoded

sleep 5
echo Enable API endpoint key-auth
http :8001/apis/chain/plugins \
    name=key-auth \
    config.hide_credentials=false

echo Create ACL plugin to application to use specific service. Whitelist chain-users only all else are blacklisted
http -v :8001/apis/chain/plugins  \
    name=acl \
    config.whitelist=chain-group
    

echo Create terminate plugin for anonymous access
http -v :8001/apis/chain/plugins \
    name=request-termination \
    config.status_code=403 \
    config.message=Hasta\ la\ vista

echo Create Oauth2 for user grants for application with scopes
http -v :8001/apis/chain/plugins \
   name=oauth2 \
   config.enable_password_grant=true \
   config.scopes=email
##   config.enable_authorization_code=true
##   config.mandatory_scope=true


##### Testing
echo Testing :8000/chain endpoint
http -v :8000/ Host:mock.dev

http -v :800/oauth2/token \
    Hosts:mock.dev \
#    Authorization:Basic czZCakmlkkE0MzpnWDFmQmF0M2JW \
    client_id=chain-id \
    client_secret=chain-secret \
    grant_type=password \
    scope=email \
    provision_key=XXX \
    authenticated_userid=chain-user \
    username=chain-user \
    password=chain-secret
