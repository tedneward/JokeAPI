#!/usr/bin/env bash
set -euo pipefail
source ./00_env.sh

id=$(cat created_id.txt)
echo "Deleting joke $id"
curl -s -X DELETE -w "\nHTTP:%{http_code}\n" "$BASE_URL/jokes/$id"
