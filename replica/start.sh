#!/bin/bash
set -e
printf "Waiting for an instance ."

if docker-compose exec -T mongo0 mongo --version >/dev/null 2>&1; then
  MONGO_CLI=mongo
else
  MONGO_CLI=mongosh
fi

while ! docker-compose exec -T mongo0 $MONGO_CLI --eval "db.getMongo()" >/dev/null 2>&1; do
  printf "."
  sleep 1
done
printf "OK\n"

printf "Initializing the replicaset ..."
docker-compose exec -T mongo0 $MONGO_CLI --quiet /scripts/init.js
printf "OK\n"
