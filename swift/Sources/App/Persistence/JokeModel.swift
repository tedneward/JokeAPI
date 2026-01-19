import Fluent
import Foundation

final class JokeModel: Model {
    static let schema = "jokes"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "setup")
    var setup: String
    
    @Field(key: "punchline")
    var punchline: String
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "source")
    var source: String
    
    @Field(key: "lol_count")
    var lolCount: Int
    
    @Field(key: "groan_count")
    var groanCount: Int
    
    init() {}
    
    init(
        id: UUID? = UUID(),
        setup: String,
        punchline: String,
        category: String = "",
        source: String = "",
        lolCount: Int = 0,
        groanCount: Int = 0
    ) {
        self.id = id
        self.setup = setup
        self.punchline = punchline
        self.category = category
        self.source = source
        self.lolCount = lolCount
        self.groanCount = groanCount
    }
    
    func toDomain() -> Joke {
        Joke(
            id: self.id?.uuidString ?? UUID().uuidString,
            setup: self.setup,
            punchline: self.punchline,
            category: self.category,
            source: self.source,
            lolCount: self.lolCount,
            groanCount: self.groanCount
        )
    }
}

struct CreateJokeMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(JokeModel.schema)
            .id()
            .field("setup", .string, .required)
            .field("punchline", .string, .required)
            .field("category", .string, .required)
            .field("source", .string, .required)
            .field("lol_count", .int, .required)
            .field("groan_count", .int, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(JokeModel.schema).delete()
    }
}
