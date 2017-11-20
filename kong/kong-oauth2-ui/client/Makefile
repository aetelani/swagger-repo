
# docker
build:
	docker build . -t poc-client

clean:
	docker stop poc-client || true
	docker rm -v poc-client || true

start:
	#docker network create poc-net
	docker run --rm --name poc-client -it --link kong:kong -p 3000:3000 poc-client:latest

# npm, Does update at host
update_host:
	sudo npm i -g npm-check-updates
	sudo npm-check-updates -u
	sudo npm install
