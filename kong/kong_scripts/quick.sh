http :8001/apis name=httpbin uris=/products upstream_url=http://httpbin.org
http :8001/apis/httpbin/plugins name=key-auth
http :8001/consumers username=ae
http :8001/consumers/ae/key-auth key=passmein
http :8000/products apikey:passmein
