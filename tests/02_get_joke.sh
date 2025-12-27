#!/usr/bin/env bash
set -euo pipefail
source ./00_env.sh

id=$(cat created_id.txt)
echo "Getting joke $id"
curl -s -D - "$BASE_URL/jokes/$id" | sed -n '1,200p'
