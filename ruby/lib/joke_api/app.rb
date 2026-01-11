require "sinatra"
require "json"
require_relative "database"
require_relative "models/joke"
require_relative "repository"

module JokeAPI
  class App < Sinatra::Base
    set :bind, "0.0.0.0"
    set :port, 8000
    set :server, :puma
    
    before do
      content_type :json
      @repo = Repository.new
    end

    after do
      @repo.close
    end

    # GET /jokes - List jokes with optional filtering
    get "/jokes" do
      source = params["source"]
      category = params["category"]
      limit = (params["limit"] || 100).to_i
      offset = (params["offset"] || 0).to_i

      jokes = @repo.list_jokes(source: source, category: category, limit: limit, offset: offset)
      jokes.map(&:to_h).to_json
    end

    # POST /jokes - Create a new joke
    post "/jokes" do
      payload = JSON.parse(request.body.read)
      setup = payload["setup"]
      punchline = payload["punchline"]
      category = payload["category"] || ""
      source = payload["source"] || "me"

      joke = @repo.create_joke(setup, punchline, category, source)
      status 201
      headers["Location"] = "/jokes/#{joke.id}"
      joke.to_h.to_json
    end

    # GET /jokes/random - Get a random joke
    get "/jokes/random" do
      category = params["category"]
      joke = @repo.random_joke(category)

      if joke
        joke.to_h.to_json
      else
        status 404
        { error: "No jokes found" }.to_json
      end
    end

    # GET /jokes/:id - Get a specific joke
    get "/jokes/:id" do
      joke = @repo.get_joke(params["id"].to_i)

      if joke
        joke.to_h.to_json
      else
        status 404
        { error: "Not found" }.to_json
      end
    end

    # PUT /jokes/:id - Update a joke
    put "/jokes/:id" do
      payload = JSON.parse(request.body.read)
      
      # Get the existing joke first
      existing_joke = @repo.get_joke(params["id"].to_i)
      unless existing_joke
        status 404
        { error: "Not found" }.to_json
        break
      end
      
      # Only update fields that were provided in the request
      setup = payload["setup"] || existing_joke.setup
      punchline = payload["punchline"] || existing_joke.punchline
      category = payload.key?("category") ? (payload["category"] || "") : existing_joke.category
      source = payload.key?("source") ? (payload["source"] || "me") : existing_joke.source

      joke = @repo.update_joke(params["id"].to_i, setup: setup, punchline: punchline, category: category, source: source)

      if joke
        joke.to_h.to_json
      else
        status 404
        { error: "Not found" }.to_json
      end
    end

    # DELETE /jokes/:id - Delete a joke
    delete "/jokes/:id" do
      success = @repo.delete_joke(params["id"].to_i)

      if success
        status 204
      else
        status 404
        { error: "Not found" }.to_json
      end
    end

    # POST /jokes/:id/bump-lol - Increment LOL count
    post "/jokes/:id/bump-lol" do
      lol_count = @repo.increment_lol(params["id"].to_i)

      if lol_count
        joke = @repo.get_joke(params["id"].to_i)
        { id: joke.id, lolCount: joke.lol_count, groanCount: joke.groan_count }.to_json
      else
        status 404
        { error: "Not found" }.to_json
      end
    end

    # POST /jokes/:id/bump-groan - Increment groan count
    post "/jokes/:id/bump-groan" do
      groan_count = @repo.increment_groan(params["id"].to_i)

      if groan_count
        joke = @repo.get_joke(params["id"].to_i)
        { id: joke.id, lolCount: joke.lol_count, groanCount: joke.groan_count }.to_json
      else
        status 404
        { error: "Not found" }.to_json
      end
    end

    # Root endpoint
    get "/" do
      { status: "ok" }.to_json
    end
  end
end
