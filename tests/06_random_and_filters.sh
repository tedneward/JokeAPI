#!/usr/bin/env bash
set -euo pipefail
source ./00_env.sh

echo "Get a random joke"
curl -s -X GET "$BASE_URL/jokes/random" -H "$CONTENT_TYPE" -w "\nHTTP:%{http_code}\n"

echo "Get random joke in category 'Classic'"
curl -s -X GET "$BASE_URL/jokes/random?category=Classic" -H "$CONTENT_TYPE" -w "\nHTTP:%{http_code}\n"

echo "List jokes by source 'ted'"
curl -s -X GET "$BASE_URL/jokes?source=ted" -H "$CONTENT_TYPE" -w "\nHTTP:%{http_code}\n"
