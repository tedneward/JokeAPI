#!/bin/bash
set -euo pipefail

echo "Building JokeAPI C++ implementation..."

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake .. || {
    echo "CMake configuration failed"
    exit 1
}

# Build the project
make || {
    echo "Build failed"
    exit 1
}

echo "Build completed successfully"