# AI Development Guidelines

These rules apply to any automated or AI-assisted code changes.

## General Rules
- Prefer small, incremental changes
- Do not introduce new dependencies without approval
- Do not change public APIs unless explicitly instructed

## Code Quality
- Maintain existing style and formatting
- Favor clarity over cleverness
- Add tests for new behavior

## Testing
- All changes must keep existing tests passing
- If tests fail, fix implementation, not tests (unless instructed)

## Architecture Constraints
- Domain layer must not depend on persistence or HTTP layers
- Repository interfaces live in the domain layer
- All data resides in a SQLite database fully managed by the implementation
- If a SQLite database file does not exist on startup, the implementation must create one

## When Unsure
- Ask clarifying questions before making assumptions

## Consistency
- Each time tests are passing, ask about committing code to Git
- Never delete or commit anything without asking first
