import Fluent
import Foundation

class FluentJokeRepository: JokeRepository {
    private let database: Database
    
    init(_ database: Database) {
        self.database = database
    }
    
    func create(joke: JokeCreate) async throws -> Joke {
        let id = UUID()
        let model = JokeModel(
            id: id,
            setup: joke.setup ?? "",
            punchline: joke.punchline ?? "",
            category: joke.category ?? "",
            source: joke.source ?? "",
            lolCount: 0,
            groanCount: 0
        )
        try await model.save(on: database)
        return model.toDomain()
    }
    
    func getById(_ id: String) async throws -> Joke? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        guard let model = try await JokeModel.find(uuid, on: database) else { return nil }
        return model.toDomain()
    }
    
    func getAll(source: String?, category: String?, limit: Int, offset: Int) async throws -> [Joke] {
        var query = JokeModel.query(on: database)
        
        if let source = source {
            query = query.filter(\.$source == source)
        }
        
        if let category = category {
            query = query.filter(\.$category == category)
        }
        
        let models = try await query
            .offset(offset)
            .limit(limit)
            .all()
        
        return models.map { $0.toDomain() }
    }
    
    func update(id: String, joke: JokeCreate) async throws -> Joke? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        guard var model = try await JokeModel.find(uuid, on: database) else { return nil }
        
        // Only update fields that are provided
        if let setup = joke.setup {
            model.setup = setup
        }
        if let punchline = joke.punchline {
            model.punchline = punchline
        }
        if let category = joke.category {
            model.category = category
        }
        if let source = joke.source {
            model.source = source
        }
        
        try await model.update(on: database)
        return model.toDomain()
    }
    
    func delete(id: String) async throws -> Bool {
        guard let uuid = UUID(uuidString: id) else { return false }
        guard let model = try await JokeModel.find(uuid, on: database) else { return false }
        try await model.delete(on: database)
        return true
    }
    
    func getRandom(category: String?) async throws -> Joke? {
        var query = JokeModel.query(on: database)
        
        if let category = category {
            query = query.filter(\.$category == category)
        }
        
        let count = try await query.count()
        guard count > 0 else { return nil }
        
        let randomOffset = Int.random(in: 0..<count)
        let models = try await query.offset(randomOffset).limit(1).all()
        
        return models.first?.toDomain()
    }
    
    func bumpLol(id: String) async throws -> CountsResponse? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        guard var model = try await JokeModel.find(uuid, on: database) else { return nil }
        
        model.lolCount += 1
        try await model.update(on: database)
        
        return CountsResponse(
            id: model.id?.uuidString ?? id,
            lolCount: model.lolCount,
            groanCount: model.groanCount
        )
    }
    
    func bumpGroan(id: String) async throws -> CountsResponse? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        guard var model = try await JokeModel.find(uuid, on: database) else { return nil }
        
        model.groanCount += 1
        try await model.update(on: database)
        
        return CountsResponse(
            id: model.id?.uuidString ?? id,
            lolCount: model.lolCount,
            groanCount: model.groanCount
        )
    }
}
