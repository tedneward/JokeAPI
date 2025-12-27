#!/usr/bin/env bash
set -euo pipefail
source ./00_env.sh

echo "Creating a joke..."
TMPBODY=$(mktemp)
code=$(curl -s -o "$TMPBODY" -w "%{http_code}" -X POST "$BASE_URL/jokes" -H "$CONTENT_TYPE" -d '{"setup":"Why did the chicken cross the road?","punchline":"To get to the other side!","category":"Classic","source":"ted"}')
echo "HTTP $code"
cat "$TMPBODY"
if [ "$code" -ne 201 ]; then
  echo "Create failed"
  rm -f "$TMPBODY"
  exit 2
fi

id=$(python3 -c "import sys, json; print(json.load(open('$TMPBODY'))['id'])")
echo "Created id: $id"
echo "$id" > created_id.txt
rm -f "$TMPBODY"
