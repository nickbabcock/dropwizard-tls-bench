#!/bin/bash

set -euo pipefail

function clean_up {
    echo "Cleaning up"
    docker-compose down
}

trap clean_up SIGHUP SIGINT SIGTERM

truncate --size 0 out.csv
docker-compose up --no-start web h2load

for i in 0 10 100 1000 10000 100000; do
    head -c $i </dev/urandom > data-$i
done;

printf "app type,endpoint type,jce provider,payload,req/s\n" > out.csv

for i in https h2; do
for j in jersey servlet servlet-nonblocking; do
for k in Conscrypt ""; do
for l in 0 10 100 1000 10000 100000; do
    BF=""
    if [[ $i == 'h2' && $k == '' ]]; then
        BF="-Xbootclasspath/p:alpn-boot-8.1.11.v20170118.jar"
    fi;

    if [[ $j == 'jersey' ]]; then
        API_PATH='api'
    else
        API_PATH='perf'
    fi;

    CMD="$BF -jar tls.bench-1.0-SNAPSHOT.jar  server config.yml"
    NAME=$(docker-compose run --use-aliases -d -e ENDPOINT_TYPE=$j -e APP_TYPE=$i -e JCE_PROVIDER=$k web $CMD)
    sleep 2

    # Warmup
    docker-compose run -v $(pwd):/tmp --rm --use-aliases h2load -N 3s --duration=10 -c100 -m10  -d /tmp/data-$l -t 2 "https://web:9443/$API_PATH" > /dev/null

    for m in {0..4}; do
        REQ=$(docker-compose run -v $(pwd):/tmp --rm --use-aliases h2load -N 3s --duration=10 -c100 -m10  -d /tmp/data-$l -t 2 "https://web:9443/$API_PATH" | grep finished | grep -o -P '(\d+\.\d+) (?=req/s)')
        printf "$i,$j,$k,$l,$REQ\n" | tee -a out.csv
    done;

    docker stop $NAME
    docker rm $NAME
done;
done;
done;
done;

echo "Done: $(date)"
