#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
IMAGE_NAME=jokeapi-ballerina:latest
CONTAINER_NAME=jokeapi-ballerina-run
if docker ps -a --format '{{.Names}}' | grep -q "${CONTAINER_NAME}"; then
  docker rm -f ${CONTAINER_NAME} || true
fi

docker run --name ${CONTAINER_NAME} -p 8000:8000 -d ${IMAGE_NAME}

echo "Started container ${CONTAINER_NAME} mapping host:8000 -> container:8000"
