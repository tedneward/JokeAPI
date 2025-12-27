#!/usr/bin/env bash
set -euo pipefail
source ./00_env.sh

id=$(cat created_id.txt)
echo "Updating joke $id"
curl -s -X PUT "$BASE_URL/jokes/$id" -H "$CONTENT_TYPE" -d '{"setup":"Updated setup","punchline":"Updated punchline","category":"Updated","source":"ted"}' -w "\nHTTP:%{http_code}\n"
