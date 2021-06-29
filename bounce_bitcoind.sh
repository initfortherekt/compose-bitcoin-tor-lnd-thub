docker-compose down
docker rmi $(docker images | grep bitcoind |  grep -E -o [0-9a-f]{12})
docker-compose up
