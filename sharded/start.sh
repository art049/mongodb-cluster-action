#!/bin/bash
set -e
printf "Waiting for the configsvr "

if docker-compose exec -T configsvr mongo --version >/dev/null 2>&1; then
  MONGO_CLI=mongo
else
  MONGO_CLI=mongosh
fi

while ! docker-compose exec -T configsvr $MONGO_CLI --port 27019 --eval "db.getMongo()" >/dev/null 2>&1; do
  printf "."
  sleep 1
done
printf "OK\n"
printf "Initializing the configsvr ..."
docker-compose exec -T configsvr $MONGO_CLI --quiet --port 27019 /scripts/init-configsvr.js
printf "OK\n"

printf "Initializing the shard0 ..."
docker-compose exec -T shard0a $MONGO_CLI --quiet --port 27018 /scripts/init-shard0.js
printf "OK\n"

printf "Initializing the shard1 ..."
docker-compose exec -T shard1a $MONGO_CLI --quiet --port 27018 /scripts/init-shard1.js
printf "OK\n"

printf "Initializing the shard2 ..."
docker-compose exec -T shard2a $MONGO_CLI --quiet --port 27018 /scripts/init-shard2.js
printf "OK\n"

printf "Waiting for the router "
while ! docker-compose exec -T router $MONGO_CLI --eval "db.getMongo()" >/dev/null 2>&1; do
  printf "."
  sleep 1
done
printf "OK\n"
printf "Initializing the router ..."
docker-compose exec -T router $MONGO_CLI --quiet /scripts/init-router.js
printf "OK\n"
