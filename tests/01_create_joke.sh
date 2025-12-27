#!/usr/bin/env bash
set -euo pipefail
source ./00_env.sh

echo "Creating a joke..."
resp=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/jokes" -H "$CONTENT_TYPE" -d '{"setup":"Why did the chicken cross the road?","punchline":"To get to the other side!","category":"Classic","source":"ted"}')
body=$(echo "$resp" | sed -n '1,$p' | sed -n '1,$p' | sed -n '$d')
code=$(echo "$resp" | tail -n1)
echo "HTTP $code"
echo "$body"
if [ "$code" -ne 201 ]; then
  echo "Create failed"
  exit 2
fi

id=$(echo "$body" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")
echo "Created id: $id"
echo "$id" > created_id.txt
