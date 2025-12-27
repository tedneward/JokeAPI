#!/usr/bin/env bash
set -euo pipefail
source ./00_env.sh

id=$(cat created_id.txt)
echo "Bumping LOL for $id"
curl -s -X POST -H "$CONTENT_TYPE" "$BASE_URL/jokes/$id/bump-lol" -w "\nHTTP:%{http_code}\n"

echo "Bumping GROAN for $id"
curl -s -X POST -H "$CONTENT_TYPE" "$BASE_URL/jokes/$id/bump-groan" -w "\nHTTP:%{http_code}\n"
