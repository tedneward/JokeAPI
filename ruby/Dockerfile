FROM ruby:3.3-slim

WORKDIR /app

# Install required system packages
RUN apt-get update && apt-get install -y \
    sqlite3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install Ruby gems
RUN bundle install

# Copy application code
COPY . .

# Fix line endings if needed
RUN find . -name "*.rb" -exec sed -i 's/\r$//' {} \;

# Expose port 8000
EXPOSE 8000

# Initialize database on startup
RUN mkdir -p /app && cd /app

# Run the server by default
CMD ["ruby", "-I./lib", "bin/server.rb"]
