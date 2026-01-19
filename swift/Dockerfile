FROM swift:6.2.3-jammy AS build

WORKDIR /build
COPY . .

# Build the application
RUN swift build -c release --static-swift-stdlib

# Extract the executable
RUN cp .build/release/App /app

FROM ubuntu:jammy

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app /app

EXPOSE 8000

ENTRYPOINT ["/app"]
