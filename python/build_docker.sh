#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
IMAGE_NAME=jokeapi-python:latest
docker build -t ${IMAGE_NAME} .

echo "Built ${IMAGE_NAME}"
