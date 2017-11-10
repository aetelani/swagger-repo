
# Stop and remove old kong containers
docker stop kong-dashboard kong kong-database
docker rm -v kong-dashboard kong kong-database

#
docker run -d --name kong-database \
                -p 5432:5432 \
                -e "POSTGRES_USER=kong" \
                -e "POSTGRES_DB=kong" \
                postgres:9.4

# Wait database to sgtart
sleep 10
docker run --rm \
    --link kong-database:kong-database \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-database" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    kong kong migrations up

#
sleep 10
docker run -d --name kong \
    --link kong-database:kong-database \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_PG_HOST=kong-database" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    kong

#
sleep 10
#docker run --name kong-dashboard -d -p 8080:8080 pgbi/kong-dashboard:v2
docker run -p 1337:1337 \
    --link kong:kong \
    --name konga \
    pantsel/konga