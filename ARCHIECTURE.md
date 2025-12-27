# Architecture Overview

## Layers
Each language implementation (Ballerina, Jolie, LoopbackJS) is entirely independent of every other--no implementation may depend on any other implementation in any way, shape, or form.

### Domain
- Business rules
- If the language implementation doesn't provide API functionality out of the box, make use of **one** framework for all implementation needs.

### Persistence
- SQLite plus whatever language implementation library uses to generate SQL against that SQLite database
- Implements repository interfaces

### API
- Consistent API, described in `README.md`
- Input validation
- Map domain errors to HTTP response codes

## Data Flow

HTTP request -> API layer -> Domain services -> Repository -> Database

## Non-goals
- No background jobs
- No distributed transaction
- No authentication or authorization logic
- No physical separation of layers--everything runs in one process

