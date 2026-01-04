#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./gradlew clean test shadowJar
docker build -t joke-kotlin:latest .
echo "Built joke-kotlin:latest"
