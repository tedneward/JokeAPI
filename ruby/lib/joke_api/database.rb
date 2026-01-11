require "sqlite3"
require "fileutils"

module JokeAPI
  class Database
    DB_FILE = "jokes.db"

    def self.init
      return if File.exist?(DB_FILE)

      db = SQLite3::Database.new(DB_FILE)
      db.results_as_hash = true

      db.execute <<~SQL
        CREATE TABLE jokes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          setup TEXT NOT NULL,
          punchline TEXT NOT NULL,
          category TEXT NOT NULL DEFAULT '',
          source TEXT NOT NULL DEFAULT 'me',
          lol_count INTEGER NOT NULL DEFAULT 0,
          groan_count INTEGER NOT NULL DEFAULT 0
        )
      SQL

      db.close
    end

    def self.connection
      db = SQLite3::Database.new(DB_FILE)
      db.results_as_hash = true
      db
    end
  end
end
