# Swift Vapor Joke API - Deployment Guide

This document provides comprehensive instructions for deploying the Swift Vapor implementation of the Joke API.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development](#local-development)
3. [Building](#building)
4. [Testing](#testing)
5. [Docker Deployment](#docker-deployment)
6. [Configuration](#configuration)
7. [API Reference](#api-reference)
8. [Database](#database)
9. [Monitoring & Troubleshooting](#monitoring--troubleshooting)
10. [Performance Considerations](#performance-considerations)

---

## Prerequisites

### System Requirements
- **macOS**: 10.15+ or **Linux**: Ubuntu 20.04+ / Debian 11+
- **Swift**: 6.2.3 or later (install from [swift.org](https://www.swift.org/download))
- **Docker**: 20.10+ (for containerized deployment)

### Swift Installation
Check your Swift version:
```bash
swift --version
```

Install Swift if not present:
```bash
# macOS (via Homebrew)
brew install swift

# Linux (Ubuntu/Debian)
curl -s https://download.swift.org/swift-6.2.3-release/ubuntu2204/swift-6.2.3-RELEASE/swift-6.2.3-RELEASE-ubuntu22.04.tar.gz | tar xz
```

---

## Local Development

### Project Structure
```
.
├── Package.swift                 # SPM manifest
├── Sources/App/
│   ├── main.swift               # Application entry point
│   ├── configure.swift          # Server configuration
│   ├── Routes.swift             # HTTP route handlers
│   ├── Extensions.swift         # Application extensions (DI)
│   ├── Domain/
│   │   ├── Joke.swift           # Domain models
│   │   └── JokeRepository.swift  # Repository protocol
│   └── Persistence/
│       ├── JokeModel.swift      # Fluent ORM model
│       └── FluentJokeRepository.swift  # Repository implementation
├── Tests/AppTests/
│   └── JokeRepositoryTests.swift # Unit tests
├── Dockerfile                    # Docker build configuration
└── docker-compose.yml           # (Optional) For local deployment
```

### Getting Started

1. **Clone/Navigate to the project:**
```bash
cd /path/to/JokeAPI/swift
```

2. **Resolve dependencies:**
```bash
swift package resolve
```

3. **Build the project:**
```bash
swift build
```

4. **Run tests:**
```bash
swift test
```

5. **Start the server:**
```bash
swift run App
```

The server will start on `http://localhost:8000`.

---

## Building

### Development Build
```bash
swift build
```
Creates unoptimized debug binaries (faster compilation, larger binary size).

### Release Build
```bash
swift build -c release
```
Creates optimized release binaries (slower compilation, smaller binary size, better performance).

### Build Output
Compiled binaries are located in `.build/debug/` or `.build/release/`:
```bash
# Run release binary directly
.build/release/App
```

### Build Troubleshooting

**Problem: "Cannot load package manifest"**
```bash
rm -rf .build Package.resolved
swift package resolve
swift build
```

**Problem: "Unknown platform"**
- Ensure Swift 6.2.3+ is installed
- Update to latest Swift version if needed

---

## Testing

### Run All Tests
```bash
swift test
```

### Run Specific Test Suite
```bash
swift test --filter JokeRepositoryTests
```

### Run Tests with Verbose Output
```bash
swift test -v
```

### Test Coverage (Xcode)
```bash
swift test --generate-linker-flags
```

### Expected Test Results
All 20 tests should pass:
- `testCreateJoke`
- `testCreateJokeWithDefaults`
- `testGetById` / `testGetByIdNotFound`
- `testGetAll` (with various filter combinations)
- `testGetAllWithSourceFilter`
- `testGetAllWithCategoryFilter`
- `testGetAllWithLimitAndOffset`
- `testUpdate` / `testUpdateNotFound`
- `testDelete` / `testDeleteNotFound`
- `testGetRandom` / `testGetRandomWithCategory`
- `testGetRandomEmpty`
- `testBumpLol` / `testBumpGroan`
- `testBumpBothCounters`

---

## Docker Deployment

### Quick Start

1. **Build Docker Image:**
```bash
./build_docker.sh
```
Creates image `joke-api-swift:latest` (multi-stage build, ~87s).

2. **Run Docker Container:**
```bash
./run_docker.sh
```
Starts container with:
- Port mapping: `8000:8000`
- Auto-cleanup on exit (`--rm`)
- Ephemeral data (no volumes)

3. **Verify Container:**
```bash
curl http://localhost:8000/jokes
```

### Manual Docker Commands

**Build Image:**
```bash
docker build -t joke-api-swift:latest .
```

**Run Container:**
```bash
docker run --rm -p 8000:8000 joke-api-swift:latest
```

**Run with Volume (Persistent Data):**
```bash
docker run --rm -p 8000:8000 \
  -v joke-data:/app/data \
  joke-api-swift:latest
```

**View Container Logs:**
```bash
docker logs <container-id>
```

**Stop Container:**
```bash
docker stop <container-id>
```

### Docker Compose (Optional)

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  joke-api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - LOG_LEVEL=info
    # Uncomment for persistent data
    # volumes:
    #   - joke-data:/app/data
    # volumes:
    #   joke-data:

```

Run with Docker Compose:
```bash
docker-compose up
```

### Multi-Environment Deployment

**Staging:**
```bash
docker build -t joke-api-swift:staging .
docker run -d --name joke-api-staging \
  -p 8001:8000 \
  -e LOG_LEVEL=debug \
  joke-api-swift:staging
```

**Production:**
```bash
docker build -t joke-api-swift:latest .
docker push myregistry.azurecr.io/joke-api-swift:latest

# On production server
docker pull myregistry.azurecr.io/joke-api-swift:latest
docker run -d --name joke-api \
  -p 8000:8000 \
  -v joke-data:/app/data \
  -e LOG_LEVEL=info \
  myregistry.azurecr.io/joke-api-swift:latest
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_LEVEL` | `info` | Logging level: `debug`, `info`, `warning`, `error` |
| `PORT` | `8000` | HTTP server port |
| `HOST` | `0.0.0.0` | Server bind address |
| `DB_PATH` | `db.sqlite` | SQLite database file path |

### Runtime Configuration

**Set Environment Variables:**
```bash
# Shell
export LOG_LEVEL=debug
export PORT=3000
swift run App

# Docker
docker run -e LOG_LEVEL=debug -e PORT=3000 -p 3000:3000 joke-api-swift:latest
```

### Application Configuration

Edit `Sources/App/configure.swift` to modify:
- Server address/port binding
- Database location
- Middleware stack
- Migrations
- Content coders

Example - Change port:
```swift
app.http.server.configuration.address = .hostname("0.0.0.0", port: 3000)
```

Example - Enable debug logging:
```bash
export LOG_LEVEL=debug
swift run App
```

---

## API Reference

### Base URL
```
http://localhost:8000
```

### Endpoints

#### List Jokes
```
GET /jokes?source=<string>&category=<string>&limit=<int>&offset=<int>
```
**Query Parameters:**
- `source` (optional): Filter by source
- `category` (optional): Filter by category
- `limit` (optional, default: 10): Number of results
- `offset` (optional, default: 0): Pagination offset

**Response:**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "setup": "Why did the chicken cross the road?",
    "punchline": "To get to the other side.",
    "category": "Classic",
    "source": "traditional",
    "lolCount": 5,
    "groanCount": 2
  }
]
```

#### Create Joke
```
POST /jokes
Content-Type: application/json

{
  "setup": "Why did the programmer quit?",
  "punchline": "He didn't get arrays.",
  "category": "Programming",
  "source": "tech"
}
```

**Response:** `201 Created`
```
Location: /jokes/550e8400-e29b-41d4-a716-446655440000
```

#### Get Random Joke
```
GET /jokes/random?category=<string>
```

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "setup": "Why did the chicken cross the road?",
  "punchline": "To get to the other side.",
  "category": "Classic",
  "source": "traditional",
  "lolCount": 5,
  "groanCount": 2
}
```

#### Get Joke by ID
```
GET /jokes/{id}
```

**Response:** `200 OK` or `404 Not Found`

#### Update Joke
```
PUT /jokes/{id}
Content-Type: application/json

{
  "category": "Updated Category"
}
```

**Response:** `200 OK` or `404 Not Found`

#### Delete Joke
```
DELETE /jokes/{id}
```

**Response:** `204 No Content` or `404 Not Found`

#### Bump Lol Count
```
POST /jokes/{id}/bump-lol
```

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "lolCount": 6,
  "groanCount": 2
}
```

#### Bump Groan Count
```
POST /jokes/{id}/bump-groan
```

**Response:** `200 OK`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "lolCount": 5,
  "groanCount": 3
}
```

### Error Responses

**400 Bad Request:**
```json
{
  "error": true,
  "reason": "Invalid request format"
}
```

**404 Not Found:**
```json
{
  "error": true,
  "reason": "The resource was not found"
}
```

**500 Internal Server Error:**
```json
{
  "error": true,
  "reason": "An internal server error occurred"
}
```

---

## Database

### SQLite Setup

**Database File:** `db.sqlite` (auto-created on startup)

### Database Schema

**jokes table:**
```sql
CREATE TABLE jokes (
  id TEXT PRIMARY KEY,
  setup TEXT NOT NULL,
  punchline TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT '',
  source TEXT NOT NULL DEFAULT '',
  lol_count INTEGER NOT NULL DEFAULT 0,
  groan_count INTEGER NOT NULL DEFAULT 0
);
```

### Database Operations

**View Database:**
```bash
# Install sqlite3 if needed
brew install sqlite3  # macOS

# Open database
sqlite3 db.sqlite

# List tables
.tables

# View schema
.schema jokes

# Query data
SELECT * FROM jokes;
```

### Database Backup & Restore

**Backup:**
```bash
cp db.sqlite db.sqlite.backup
```

**Restore:**
```bash
cp db.sqlite.backup db.sqlite
```

### Docker Volume Management

**Create Named Volume:**
```bash
docker volume create joke-data
```

**Run with Volume:**
```bash
docker run --rm -p 8000:8000 \
  -v joke-data:/app/data \
  joke-api-swift:latest
```

**Inspect Volume:**
```bash
docker volume inspect joke-data
```

---

## Monitoring & Troubleshooting

### Server Logs

**Local:**
```bash
swift run App
# Logs appear in console
```

**Docker:**
```bash
docker logs <container-id>
docker logs -f <container-id>  # Follow logs
```

### Common Issues

**1. Port Already in Use**
```bash
# Find process using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>

# Or use different port
export PORT=3000
swift run App
```

**2. Database Lock Error**
```
"SQLite Error: database is locked"
```
**Solution:**
- Ensure only one instance is running
- Check for hung processes: `ps aux | grep App`
- Remove stale database lock: `rm db.sqlite-shm`

**3. Connection Refused**
```
"connection refused localhost:8000"
```
**Solution:**
- Verify server is running: `curl http://localhost:8000/jokes`
- Check port binding: `lsof -i :8000`
- Verify host configuration in `configure.swift`

**4. Out of Memory**
```
"fatal error: Not enough memory to allocate"
```
**Solution:**
- Reduce concurrent connections
- Implement connection pooling
- Monitor memory usage: `top`

### Performance Debugging

**Enable Debug Logging:**
```bash
export LOG_LEVEL=debug
swift run App
```

**Profile with Instruments (macOS):**
```bash
swift build
instruments -t "System Trace" .build/debug/App
```

**Check Memory Usage:**
```bash
# macOS
top -o MEM

# Linux
top -o %MEM
```

---

## Performance Considerations

### Optimization Tips

1. **Use Release Build for Production:**
```bash
swift build -c release
docker build -t joke-api-swift:latest .
```

2. **Database Indexing:**
Currently, SQLite provides basic indexing. For production:
```sql
CREATE INDEX idx_category ON jokes(category);
CREATE INDEX idx_source ON jokes(source);
```

3. **Connection Pooling:**
Configure in `configure.swift` for high throughput.

4. **Caching:**
Implement Redis or in-memory cache for frequently accessed jokes.

5. **Load Balancing:**
Use nginx/HAProxy for multiple instances:
```nginx
upstream joke_api {
  server localhost:8000;
  server localhost:8001;
  server localhost:8002;
}

server {
  listen 80;
  location / {
    proxy_pass http://joke_api;
  }
}
```

### Benchmarking

**Load Testing with Apache Bench:**
```bash
# 1000 requests, 10 concurrent
ab -n 1000 -c 10 http://localhost:8000/jokes
```

**Load Testing with Wrk:**
```bash
wrk -t4 -c100 -d30s http://localhost:8000/jokes
```

### Resource Limits

**Docker Memory Limit:**
```bash
docker run --memory 512m joke-api-swift:latest
```

**Docker CPU Limit:**
```bash
docker run --cpus 1.5 joke-api-swift:latest
```

---

## Deployment Checklist

- [ ] Swift 6.2.3+ installed
- [ ] Dependencies resolved: `swift package resolve`
- [ ] Unit tests passing: `swift test`
- [ ] Release build successful: `swift build -c release`
- [ ] Docker image built: `./build_docker.sh`
- [ ] Container runs locally: `./run_docker.sh`
- [ ] API endpoints responding: `curl http://localhost:8000/jokes`
- [ ] Database initialized with data
- [ ] Logs configured appropriately
- [ ] Environment variables set
- [ ] Firewall rules allow port 8000
- [ ] SSL/TLS certificates obtained (if needed)
- [ ] Backup strategy implemented
- [ ] Monitoring set up
- [ ] Health check endpoint tested

---

## Additional Resources

- **Vapor Documentation:** https://docs.vapor.codes
- **Fluent ORM:** https://github.com/vapor/fluent
- **Swift Concurrency:** https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html
- **Docker Best Practices:** https://docs.docker.com/develop/dev-best-practices/
- **SQLite Documentation:** https://www.sqlite.org/docs.html

---

## Support & Troubleshooting

For additional help:
1. Check `README.md` for quick start guide
2. Review application logs for error details
3. Verify configuration in `Sources/App/configure.swift`
4. Consult Vapor documentation at https://docs.vapor.codes
5. Check repository issues or create new issue

---

**Last Updated:** January 2026
**Vapor Version:** 4.99.0+
**Swift Version:** 6.2.3
