#!/bin/bash
set -e

# This script tests the Ruby JokeAPI implementation
# It builds the Docker image, runs tests, and validates the API

echo "=== Building Docker image ==="
docker build -t jokeapi-ruby:test .

echo ""
echo "=== Running unit tests ==="
docker run --rm jokeapi-ruby:test bundle exec rake spec

echo ""
echo "=== Starting API server ==="
docker run -d -p 8000:8000 --name joke-api-ruby-test jokeapi-ruby:test

# Wait for server to start
sleep 3

echo ""
echo "=== Testing API with curl tests ==="
cd /tmp
python3 ../../tests/run_tests.py

# Cleanup
echo ""
echo "=== Stopping test container ==="
docker stop joke-api-ruby-test
docker rm joke-api-ruby-test

echo ""
echo "=== All tests passed! ==="
