#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
dotnet restore src/JokeApi/JokeApi.csproj
dotnet test tests/JokeApi.Tests/JokeApi.Tests.csproj --no-build --verbosity minimal
dotnet publish src/JokeApi/JokeApi.csproj -c Release -o publish
docker build -t jokeapi-csharp:latest .
echo "Built docker image jokeapi-csharp:latest"
