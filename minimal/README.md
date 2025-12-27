# Minimal Javalin implementation

This is a tiny, constant-valued implementation of the `JokeAPI` used for testing and validation.


Requirements: Java 21 and Maven installed.

Build and run:

```bash
cd javalin/minimal
mvn -q -DskipTests compile exec:java
```

The server listens on port `8000` and exposes the API root `/jokes`.

Once running you can run the repository `tests/07_sequence_run.sh` to exercise the endpoints.
