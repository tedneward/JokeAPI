# Swift/Vapor Joke API

A Swift implementation of the JokeAPI using the Vapor framework.

## Prerequisites

- Swift 5.9 or later
- macOS 13 or later (or compatible Linux system)

## Build

```bash
swift build
```

## Run Tests

```bash
swift test
```

## Run

```bash
swift run
```

The API will be available at `http://localhost:8000/jokes`

## Docker

Build the Docker image:

```bash
./build_docker.sh
```

Run the Docker image:

```bash
./run_docker.sh
```

Test with curl scripts:

```bash
cd ../tests
BASE_URL=http://localhost:8000 python3 run_tests.py
```
