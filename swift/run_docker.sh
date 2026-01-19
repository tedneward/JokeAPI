#!/bin/bash
set -e

# Run the Docker container
docker run --rm -p 8000:8000 joke-api-swift:latest

echo "Docker container stopped"
