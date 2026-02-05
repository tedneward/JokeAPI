# JokeAPI C++ Implementation

This is a C++ implementation of the JokeAPI that follows the same architecture and functionality as the other implementations in this project.

## Architecture

The implementation follows the same layered architecture pattern:

1. **Domain Layer**: Joke data model
2. **Persistence Layer**: SQLite database with JokeRepository
3. **API Layer**: HTTP server with JokeService

## Features Implemented

- Full CRUD operations for jokes
- Random joke retrieval
- Category and source filtering
- LOL and groan count bumping
- JSON serialization/deserialization

## Dependencies

- C++17 compiler
- CMake 3.10+
- SQLite3
- nlohmann/json (JSON library)

## Building

```bash
mkdir build
cd build
cmake ..
make
```

## Running

```bash
./build/jokeapi
```

## Docker

To build and run using Docker:

```bash
./build.sh
./run_docker.sh
```

The API will be available at `http://localhost:8000`.

## API Endpoints

The implementation supports all endpoints defined in `joke.api`:

- `GET /jokes` - List jokes
- `POST /jokes` - Create a joke
- `GET /jokes/{id}` - Get a joke by ID
- `PUT /jokes/{id}` - Update a joke
- `DELETE /jokes/{id}` - Delete a joke
- `GET /jokes/random` - Get a random joke
- `POST /jokes/{id}/bump-lol` - Bump LOL count
- `POST /jokes/{id}/bump-groan` - Bump groan count