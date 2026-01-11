require "rspec"
require_relative "../lib/joke_api"
require "sqlite3"

RSpec.describe JokeAPI::Repository do
  let(:db) do
    db = SQLite3::Database.new ":memory:"
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
    db
  end

  let(:repo) { JokeAPI::Repository.new(db) }

  describe "#create_joke" do
    it "creates a joke with all required fields" do
      joke = repo.create_joke("Why?", "Because.", "funny", "alice")
      expect(joke.id).not_to be_nil
      expect(joke.setup).to eq("Why?")
      expect(joke.punchline).to eq("Because.")
      expect(joke.category).to eq("funny")
      expect(joke.source).to eq("alice")
      expect(joke.lol_count).to eq(0)
      expect(joke.groan_count).to eq(0)
    end

    it "uses default values when not provided" do
      joke = repo.create_joke("Setup", "Punchline")
      expect(joke.category).to eq("")
      expect(joke.source).to eq("me")
    end

    it "handles nil category and source as empty/default" do
      joke = repo.create_joke("S", "P", nil, nil)
      expect(joke.category).to eq("")
      expect(joke.source).to eq("me")
    end
  end

  describe "#get_joke" do
    it "retrieves a joke by ID" do
      created = repo.create_joke("Q", "A", "cat", "bob")
      retrieved = repo.get_joke(created.id)
      expect(retrieved.setup).to eq("Q")
      expect(retrieved.source).to eq("bob")
    end

    it "returns nil for non-existent ID" do
      expect(repo.get_joke(999)).to be_nil
    end
  end

  describe "#list_jokes" do
    it "returns all jokes without filters" do
      repo.create_joke("Q1", "A1")
      repo.create_joke("Q2", "A2")
      jokes = repo.list_jokes
      expect(jokes.length).to eq(2)
    end

    it "filters by source" do
      repo.create_joke("Q1", "A1", "", "alice")
      repo.create_joke("Q2", "A2", "", "bob")
      jokes = repo.list_jokes(source: "alice")
      expect(jokes.length).to eq(1)
      expect(jokes.first.source).to eq("alice")
    end

    it "filters by category" do
      repo.create_joke("Q1", "A1", "cat")
      repo.create_joke("Q2", "A2", "dog")
      jokes = repo.list_jokes(category: "cat")
      expect(jokes.length).to eq(1)
      expect(jokes.first.category).to eq("cat")
    end

    it "supports pagination" do
      3.times { |i| repo.create_joke("Q#{i}", "A#{i}") }
      page1 = repo.list_jokes(limit: 2, offset: 0)
      page2 = repo.list_jokes(limit: 2, offset: 2)
      expect(page1.length).to eq(2)
      expect(page2.length).to eq(1)
    end
  end

  describe "#update_joke" do
    it "updates a joke's fields" do
      joke = repo.create_joke("Old", "Joke")
      updated = repo.update_joke(joke.id, setup: "New", punchline: "Laugh", category: "funny", source: "alice")
      expect(updated.setup).to eq("New")
      expect(updated.punchline).to eq("Laugh")
      expect(updated.category).to eq("funny")
      expect(updated.source).to eq("alice")
    end

    it "returns nil for non-existent joke" do
      result = repo.update_joke(999, setup: "X", punchline: "Y", category: "", source: "me")
      expect(result).to be_nil
    end
  end

  describe "#delete_joke" do
    it "deletes a joke" do
      joke = repo.create_joke("Q", "A")
      expect(repo.delete_joke(joke.id)).to be true
      expect(repo.get_joke(joke.id)).to be_nil
    end

    it "returns false for non-existent joke" do
      expect(repo.delete_joke(999)).to be false
    end
  end

  describe "#increment_lol" do
    it "increments the lol count" do
      joke = repo.create_joke("Q", "A")
      count1 = repo.increment_lol(joke.id)
      expect(count1).to eq(1)
      count2 = repo.increment_lol(joke.id)
      expect(count2).to eq(2)
    end

    it "returns nil for non-existent joke" do
      expect(repo.increment_lol(999)).to be_nil
    end
  end

  describe "#increment_groan" do
    it "increments the groan count" do
      joke = repo.create_joke("Q", "A")
      count1 = repo.increment_groan(joke.id)
      expect(count1).to eq(1)
      count2 = repo.increment_groan(joke.id)
      expect(count2).to eq(2)
    end

    it "returns nil for non-existent joke" do
      expect(repo.increment_groan(999)).to be_nil
    end
  end

  describe "#random_joke" do
    it "returns a random joke when jokes exist" do
      repo.create_joke("Q1", "A1", "cat")
      repo.create_joke("Q2", "A2", "dog")
      joke = repo.random_joke
      expect(joke).not_to be_nil
      expect([1, 2]).to include(joke.id)
    end

    it "returns nil when no jokes exist" do
      expect(repo.random_joke).to be_nil
    end

    it "filters by category" do
      repo.create_joke("Q1", "A1", "cat")
      repo.create_joke("Q2", "A2", "dog")
      joke = repo.random_joke("cat")
      expect(joke.category).to eq("cat")
    end

    it "returns nil when no jokes match category" do
      repo.create_joke("Q1", "A1", "cat")
      expect(repo.random_joke("bird")).to be_nil
    end
  end

  describe "#list_by_source" do
    it "returns jokes by source" do
      repo.create_joke("Q1", "A1", "", "alice")
      repo.create_joke("Q2", "A2", "", "alice")
      repo.create_joke("Q3", "A3", "", "bob")
      jokes = repo.list_by_source("alice")
      expect(jokes.length).to eq(2)
      expect(jokes.all? { |j| j.source == "alice" }).to be true
    end

    it "returns empty list for non-existent source" do
      jokes = repo.list_by_source("nobody")
      expect(jokes).to be_empty
    end
  end
end
