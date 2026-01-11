#!/usr/bin/env bash
set -euo pipefail

# Default images to test; override by passing image names as args
images=("jokeapi-csharp:latest" "jokeapi-javalin:latest" "jokeapi-kotlin:latest" "jokeapi-nestjs:latest" "jokeapi-python:latest" "jokeapi-ruby:latest")
if [ "$#" -gt 0 ]; then
  images=("$@")
fi

repo_root="$(cd "$(dirname "$0")" && pwd)"
failures=0

for img in "${images[@]}"; do
  echo
  echo "=== Testing image: $img ==="
  name="test_${img//[^a-zA-Z0-9]/_}"
  docker rm -f "$name" 2>/dev/null || true

  echo "Starting container $name from $img"
  cid=$(docker run -d -p 8000:8000 --rm --name "$name" "$img" 2>/dev/null) || {
    echo "Failed to start image: $img" >&2
    failures=$((failures+1))
    continue
  }
  echo "$cid" >/tmp/test_${name}_cid

  # wait for HTTP readiness
  ready=0
  for i in $(seq 1 40); do
    if curl -sS http://localhost:8000/ -o /dev/null 2>/dev/null; then
      echo "port open after $i attempts"
      ready=1
      break
    fi
    sleep 0.5
  done

  if [ "$ready" -ne 1 ]; then
    echo "Container did not become ready; showing logs:" >&2
    docker logs "$cid" --tail 200 || true
    docker stop "$cid" || true
    rm -f /tmp/test_${name}_cid
    failures=$((failures+1))
    continue
  fi

  echo "Running Python E2E script against http://localhost:8000"
  (cd "$repo_root" && BASE_URL=http://localhost:8000 CONTENT_TYPE=application/json python3 tests/run_tests.py)
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "Tests failed for $img (rc=$rc)" >&2
    failures=$((failures+1))
  else
    echo "Tests passed for $img"
  fi

  docker stop "$cid" >/dev/null 2>&1 || true
  rm -f /tmp/test_${name}_cid
  sleep 0.5
done

echo
echo "=== Summary ==="
if [ $failures -ne 0 ]; then
  echo "$failures image(s) failed"
  exit 1
else
  echo "All images passed"
  exit 0
fi
