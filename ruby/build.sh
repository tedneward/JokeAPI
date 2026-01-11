#!/bin/bash
set -e

# Build Docker image
echo "Building Docker image for Ruby JokeAPI..."
docker build -t jokeapi-ruby:latest .

echo "Docker image built successfully!"
echo "To run the image:"
echo "  docker run -p 8000:8000 jokeapi-ruby:latest"
