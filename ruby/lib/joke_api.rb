require_relative "joke_api/database"
require_relative "joke_api/models/joke"
require_relative "joke_api/repository"

module JokeAPI
end

# Load app only when explicitly required (for server execution)
# This prevents loading Sinatra during tests
