require "rspec"
require_relative "../lib/joke_api/models/joke"

RSpec.describe JokeAPI::Joke do
  describe "#initialize" do
    it "creates a joke with all fields" do
      joke = JokeAPI::Joke.new(
        setup: "Why?",
        punchline: "Because",
        category: "funny",
        source: "alice",
        id: 1,
        lol_count: 5,
        groan_count: 3
      )

      expect(joke.id).to eq(1)
      expect(joke.setup).to eq("Why?")
      expect(joke.punchline).to eq("Because")
      expect(joke.category).to eq("funny")
      expect(joke.source).to eq("alice")
      expect(joke.lol_count).to eq(5)
      expect(joke.groan_count).to eq(3)
    end

    it "uses default values for optional fields" do
      joke = JokeAPI::Joke.new(setup: "Q", punchline: "A")
      expect(joke.category).to eq("")
      expect(joke.source).to eq("me")
      expect(joke.lol_count).to eq(0)
      expect(joke.groan_count).to eq(0)
    end

    it "handles nil category and source as defaults" do
      joke = JokeAPI::Joke.new(setup: "Q", punchline: "A", category: nil, source: nil)
      expect(joke.category).to eq("")
      expect(joke.source).to eq("me")
    end
  end

  describe "#to_h" do
    it "converts joke to hash with correct JSON keys" do
      joke = JokeAPI::Joke.new(
        id: 42,
        setup: "Setup text",
        punchline: "Punchline text",
        category: "funny",
        source: "alice",
        lol_count: 10,
        groan_count: 5
      )

      hash = joke.to_h
      expect(hash[:id]).to eq(42)
      expect(hash[:setup]).to eq("Setup text")
      expect(hash[:punchline]).to eq("Punchline text")
      expect(hash[:category]).to eq("funny")
      expect(hash[:source]).to eq("alice")
      expect(hash[:lolCount]).to eq(10)
      expect(hash[:groanCount]).to eq(5)
    end
  end

  describe ".from_db_row" do
    it "creates a joke from a database row hash" do
      row = {
        "id" => 1,
        "setup" => "Why?",
        "punchline" => "Because",
        "category" => "cat",
        "source" => "bob",
        "lol_count" => 7,
        "groan_count" => 2
      }

      joke = JokeAPI::Joke.from_db_row(row)
      expect(joke.id).to eq(1)
      expect(joke.setup).to eq("Why?")
      expect(joke.punchline).to eq("Because")
      expect(joke.category).to eq("cat")
      expect(joke.source).to eq("bob")
      expect(joke.lol_count).to eq(7)
      expect(joke.groan_count).to eq(2)
    end
  end
end
