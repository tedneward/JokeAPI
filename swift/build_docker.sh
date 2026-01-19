#!/bin/bash
set -e

# Build the Docker image
docker build -t joke-api-swift:latest .

echo "Docker image built successfully: joke-api-swift:latest"
