#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source ./00_env.sh

echo "Run full sequence of tests against $BASE_URL"
./01_create_joke.sh
./02_get_joke.sh
./03_update_joke.sh
./05_bump_counts.sh
./06_random_and_filters.sh
./04_delete_joke.sh

echo "All done"
