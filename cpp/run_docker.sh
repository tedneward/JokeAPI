#!/bin/bash
set -euo pipefail

echo "Running JokeAPI C++ implementation in Docker..."

# Build the Docker image
echo "Building Docker image..."
docker build -t jokeapi-cpp:latest .

# Run the container
echo "Starting container..."
docker run -d -p 8000:8000 --rm --name jokeapi-cpp-container jokeapi-cpp:latest

echo "Container started. You can test the API at http://localhost:8000"
echo "To stop the container, run: docker stop jokeapi-cpp-container"