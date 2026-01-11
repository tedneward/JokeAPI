module JokeAPI
  class Joke
    attr_accessor :id, :setup, :punchline, :category, :source, :lol_count, :groan_count

    def initialize(setup:, punchline:, category: "", source: "me", id: nil, lol_count: 0, groan_count: 0)
      @id = id
      @setup = setup
      @punchline = punchline
      @category = category || ""
      @source = source || "me"
      @lol_count = lol_count
      @groan_count = groan_count
    end

    def to_h
      {
        id: @id,
        setup: @setup,
        punchline: @punchline,
        category: @category,
        source: @source,
        lolCount: @lol_count,
        groanCount: @groan_count
      }
    end

    def self.from_db_row(row)
      new(
        id: row["id"],
        setup: row["setup"],
        punchline: row["punchline"],
        category: row["category"],
        source: row["source"],
        lol_count: row["lol_count"],
        groan_count: row["groan_count"]
      )
    end
  end
end
