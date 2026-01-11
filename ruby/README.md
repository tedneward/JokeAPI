# Ruby JokeAPI Implementation

A full-featured RESTful API for a Joke database, implemented in Ruby using Sinatra and SQLite.

## Architecture

The project follows a three-layer architecture:

- **Domain Layer** (`lib/joke_api/models/`): Business objects (Joke) with no framework dependencies
- **Persistence Layer** (`lib/joke_api/repository.rb`): SQLite-based data access using the `sqlite3` gem
- **API Layer** (`lib/joke_api/app.rb`): HTTP endpoints implemented with Sinatra

## Project Structure

```
ruby/
├── Gemfile              # Ruby gem dependencies
├── Rakefile             # Build and test tasks
├── Dockerfile           # Docker containerization
├── build.sh             # Docker build script
├── lib/
│   ├── joke_api.rb      # Main module loader
│   ├── joke_api/
│   │   ├── app.rb       # Sinatra application and HTTP routes
│   │   ├── database.rb  # SQLite database initialization
│   │   ├── repository.rb # Data access layer
│   │   └── models/
│   │       └── joke.rb  # Joke domain model
├── bin/
│   └── server.rb        # Server entry point
├── spec/
│   ├── joke_spec.rb     # Domain model tests
│   └── repository_spec.rb # Persistence layer tests
└── .gitignore
```

## Setup

### Local Development

1. Install Ruby 3.3+ and Bundler
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run unit tests:
   ```bash
   bundle exec rake spec
   ```

4. Initialize the database:
   ```bash
   bundle exec rake db:init
   ```

5. Start the server:
   ```bash
   bundle exec rake server
   ```

The server will start on `http://localhost:8000`.

### Docker Deployment

Build the Docker image:
```bash
./build.sh
```

Run the container:
```bash
docker run -p 8000:8000 joke-api-ruby:latest
```

The API will be available at `http://localhost:8000`.

## API Endpoints

All endpoints require `Content-Type: application/json`.

### Jokes Collection

- `GET /jokes` - List jokes (supports pagination, filtering by source/category)
  - Query parameters: `source`, `category`, `limit` (default: 100), `offset` (default: 0)
- `POST /jokes` - Create a new joke
  - Body: `{ "setup": "...", "punchline": "...", "category": "...", "source": "..." }`

### Random Jokes

- `GET /jokes/random` - Get a random joke
- `GET /jokes/random?category=X` - Get a random joke from a specific category

### Individual Jokes

- `GET /jokes/{id}` - Get a specific joke
- `PUT /jokes/{id}` - Update a joke (partial updates allowed)
- `DELETE /jokes/{id}` - Delete a joke

### Engagement Endpoints

- `POST /jokes/{id}/bump-lol` - Increment the LOL count
- `POST /jokes/{id}/bump-groan` - Increment the groan count

## Data Model

Each Joke has:

- `id` (integer, auto-generated): Unique identifier
- `setup` (string, required): The setup text
- `punchline` (string, required): The punchline text
- `category` (string, default: ""): Optional category
- `source` (string, default: "me"): Author or source of the joke
- `lolCount` (integer, default: 0): Number of LOLs
- `groanCount` (integer, default: 0): Number of groans

## Testing

### Unit Tests

Run the test suite with RSpec:
```bash
bundle exec rake spec
```

Tests cover:
- Domain model creation and serialization
- Repository CRUD operations
- Repository querying and filtering
- Database constraints

### Integration Tests

The project includes Python-based integration tests in the main project's `tests/` directory. These test the running API instance:

```bash
python tests/run_tests.py
```

## Database

The application uses SQLite with an automatically created `jokes.db` file in the working directory. The database schema is created on first run if it doesn't exist.

The `jokes` table includes:
- Unique auto-incrementing primary key
- NOT NULL constraints on setup and punchline
- Default values for category, source, lol_count, and groan_count

## Technologies

- **Ruby 3.3**: Language runtime
- **Sinatra 3.0**: Web framework
- **SQLite3**: Database
- **RSpec 3.12**: Testing framework
- **Puma**: Application server

## Development Notes

- The domain layer is completely independent of the persistence and HTTP layers
- The repository uses SQLite's `sqlite3` gem for database access
- All data is stored locally in SQLite; no external databases required
- The API includes proper HTTP status codes (201 for created, 204 for delete, 404 for not found, etc.)
- Partial updates are supported on the PUT endpoint
