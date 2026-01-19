import Foundation

protocol JokeRepository {
    func create(joke: JokeCreate) async throws -> Joke
    func getById(_ id: String) async throws -> Joke?
    func getAll(source: String?, category: String?, limit: Int, offset: Int) async throws -> [Joke]
    func update(id: String, joke: JokeCreate) async throws -> Joke?
    func delete(id: String) async throws -> Bool
    func getRandom(category: String?) async throws -> Joke?
    func bumpLol(id: String) async throws -> CountsResponse?
    func bumpGroan(id: String) async throws -> CountsResponse?
}
