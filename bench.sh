#!/bin/bash

set -euo pipefail

function clean_up {
    echo "Cleaning up"
    docker-compose down
}

: "${NGHTTP2_DIR:?Need to set NGHTTP2_DIR}"

trap clean_up SIGHUP SIGINT SIGTERM

docker-compose build web

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
    NAME=$(docker-compose run -d -e ENDPOINT_TYPE=$j -e APP_TYPE=$i -e JCE_PROVIDER=$k --service-ports web $CMD)
    sleep 2

    "$NGHTTP2_DIR/src/h2load" -N 3s --duration=10 -c100 -m10 -d data-$l -t 2 "https://localhost:9443/$API_PATH" >/dev/null

    for m in {0..4}; do
        REQ=$("$NGHTTP2_DIR/src/h2load" -N 3s -n100000 -c100 -m10 -d data-$l -t 2 "https://localhost:9443/$API_PATH" | grep finished | grep -o -P '(\d+\.\d+) (?=req/s)')
        printf "$i,$j,$k,$l,$REQ\n" | tee -a out.csv
    done;

    docker stop $NAME
    docker rm $NAME
done;
done;
done;
done;

echo "Done: $(date)"
