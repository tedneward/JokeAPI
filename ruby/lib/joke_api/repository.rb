module JokeAPI
  class Repository
    def initialize(db = nil)
      @db = db || Database.connection
    end

    # List all jokes with optional filtering and pagination
    def list_jokes(source: nil, category: nil, limit: 100, offset: 0)
      query = "SELECT * FROM jokes"
      params = []

      conditions = []
      conditions << "source = ?" if source
      conditions << "category = ?" if category

      if conditions.any?
        query += " WHERE " + conditions.join(" AND ")
        params << source if source
        params << category if category
      end

      query += " LIMIT ? OFFSET ?"
      params << limit << offset

      rows = @db.execute(query, params)
      rows.map { |row| Joke.from_db_row(row) }
    end

    # Get a single joke by ID
    def get_joke(id)
      row = @db.execute("SELECT * FROM jokes WHERE id = ?", [id]).first
      return nil unless row

      Joke.from_db_row(row)
    end

    # Create a new joke
    def create_joke(setup, punchline, category = "", source = "me")
      category = category || ""
      source = source || "me"

      @db.execute(
        "INSERT INTO jokes (setup, punchline, category, source) VALUES (?, ?, ?, ?)",
        [setup, punchline, category, source]
      )

      id = @db.last_insert_row_id
      get_joke(id)
    end

    # Update an existing joke
    def update_joke(id, setup:, punchline:, category:, source:)
      joke = get_joke(id)
      return nil unless joke

      @db.execute(
        "UPDATE jokes SET setup = ?, punchline = ?, category = ?, source = ? WHERE id = ?",
        [setup, punchline, category || "", source || "me", id]
      )

      get_joke(id)
    end

    # Delete a joke
    def delete_joke(id)
      joke = get_joke(id)
      return false unless joke

      @db.execute("DELETE FROM jokes WHERE id = ?", [id])
      true
    end

    # Increment LOL count
    def increment_lol(id)
      joke = get_joke(id)
      return nil unless joke

      @db.execute(
        "UPDATE jokes SET lol_count = lol_count + 1 WHERE id = ?",
        [id]
      )

      get_joke(id).lol_count
    end

    # Increment groan count
    def increment_groan(id)
      joke = get_joke(id)
      return nil unless joke

      @db.execute(
        "UPDATE jokes SET groan_count = groan_count + 1 WHERE id = ?",
        [id]
      )

      get_joke(id).groan_count
    end

    # Get a random joke, optionally filtered by category
    def random_joke(category = nil)
      query = "SELECT * FROM jokes"
      params = []

      if category
        query += " WHERE category = ?"
        params << category
      end

      query += " ORDER BY RANDOM() LIMIT 1"

      row = @db.execute(query, params).first
      return nil unless row

      Joke.from_db_row(row)
    end

    # Get all jokes by source
    def list_by_source(source)
      rows = @db.execute("SELECT * FROM jokes WHERE source = ?", [source])
      rows.map { |row| Joke.from_db_row(row) }
    end

    def close
      @db.close if @db
    end
  end
end
