
# docker
build:
	docker build . -t poc-client

clean: # Return true in any case
	docker stop poc-client || true
	docker stop poc-redis ||| true
	docker rm -v poc-client || true
	docker rm -v poc-redis || true

start:
	#docker network create poc-net
	docker run --rm --name poc-client -it --link kong:kong -p 3000:3000 poc-client:latest

redis:
	docker run -P --name poc-redis -d redis:alpine

# npm, Does update at host
update_host:
	sudo npm i -g npm-check-updates
	sudo npm-check-updates -u
	sudo npm install
