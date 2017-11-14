#curl -i -X DELETE --url http://localhost:8001/consumers/chain-user/jwt/chain-jwt
curl -i -X DELETE http://localhost:8001/apis/chain
#http delete :8001/consumers/$(http get :8001/consumers/ custom_id=chain-user | jq .data[].i)
http delete :8001/consumers/chain-user
