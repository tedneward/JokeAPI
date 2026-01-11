#!/bin/bash
set -euo pipefail

# Build all Docker images for JokeAPI implementations

# Build csharp Docker image
echo "Building csharp Docker image..."
cd csharp; ./build.sh; cd ..

# Build javalin Docker image
echo "Building javalin Docker image..."
cd javalin; ./gradlew dockerBuild; cd ..

# Build kotlin Docker image
echo "Building kotlin Docker image..."
cd kotlin; ./gradlew dockerBuild; cd ..

# Build nestjs Docker image
echo "Building nestjs Docker image..."
cd nestjs; npm run docker-build; cd ..

# Build python Docker image
echo "Building python Docker image..."
cd python; ./build_docker.sh; cd ..

# Build ruby Docker image
echo "Building ruby Docker image..."
cd ruby; ./build.sh; cd ..

echo "All Docker images built successfully!"
echo "You can now run the images using 'docker run -p 8000:8000 <image_name>:latest'"

