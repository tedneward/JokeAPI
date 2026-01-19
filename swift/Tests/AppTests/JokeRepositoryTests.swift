import XCTest
import Vapor
import Fluent
import FluentSQLiteDriver

@testable import App

final class JokeRepositoryTests: XCTestCase {
    var app: Application!
    var repository: JokeRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        var env = Environment.testing
        let app = Application(env)
        self.app = app
        
        // Configure with in-memory SQLite for testing
        app.databases.use(.sqlite(.memory), as: .sqlite)
        
        // Configure migrations
        app.migrations.add(CreateJokeMigration())
        
        // Run migrations
        try await app.autoMigrate()
        
        // Setup repository
        repository = FluentJokeRepository(app.db)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        app.shutdown()
    }
    
    func testCreateJoke() async throws {
        let jokeCreate = JokeCreate(
            setup: "Why did the chicken cross the road?",
            punchline: "To get to the other side!",
            category: "Classic",
            source: "ted"
        )
        
        let joke = try await repository.create(joke: jokeCreate)
        
        XCTAssertNotNil(joke.id)
        XCTAssertEqual(joke.setup, "Why did the chicken cross the road?")
        XCTAssertEqual(joke.punchline, "To get to the other side!")
        XCTAssertEqual(joke.category, "Classic")
        XCTAssertEqual(joke.source, "ted")
        XCTAssertEqual(joke.lolCount, 0)
        XCTAssertEqual(joke.groanCount, 0)
    }
    
    func testCreateJokeWithDefaults() async throws {
        let jokeCreate = JokeCreate(
            setup: "Setup text",
            punchline: "Punchline text",
            category: nil,
            source: nil
        )
        
        let joke = try await repository.create(joke: jokeCreate)
        
        XCTAssertEqual(joke.category, "")
        XCTAssertEqual(joke.source, "")
    }
    
    func testGetById() async throws {
        let jokeCreate = JokeCreate(
            setup: "Setup",
            punchline: "Punchline",
            category: "Test",
            source: "test"
        )
        
        let created = try await repository.create(joke: jokeCreate)
        let retrieved = try await repository.getById(created.id)
        
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, created.id)
        XCTAssertEqual(retrieved?.setup, created.setup)
    }
    
    func testGetByIdNotFound() async throws {
        let retrieved = try await repository.getById("invalid-id")
        XCTAssertNil(retrieved)
    }
    
    func testGetAll() async throws {
        let joke1 = try await repository.create(joke: JokeCreate(
            setup: "Setup 1",
            punchline: "Punchline 1",
            category: "Category1",
            source: "source1"
        ))
        
        let joke2 = try await repository.create(joke: JokeCreate(
            setup: "Setup 2",
            punchline: "Punchline 2",
            category: "Category2",
            source: "source2"
        ))
        
        let all = try await repository.getAll(source: nil, category: nil, limit: 100, offset: 0)
        
        XCTAssertEqual(all.count, 2)
        XCTAssertTrue(all.map { $0.id }.contains(joke1.id))
        XCTAssertTrue(all.map { $0.id }.contains(joke2.id))
    }
    
    func testGetAllWithSourceFilter() async throws {
        let _ = try await repository.create(joke: JokeCreate(
            setup: "Setup 1",
            punchline: "Punchline 1",
            category: nil,
            source: "alice"
        ))
        
        let _ = try await repository.create(joke: JokeCreate(
            setup: "Setup 2",
            punchline: "Punchline 2",
            category: nil,
            source: "bob"
        ))
        
        let alice = try await repository.getAll(source: "alice", category: nil, limit: 100, offset: 0)
        let bob = try await repository.getAll(source: "bob", category: nil, limit: 100, offset: 0)
        
        XCTAssertEqual(alice.count, 1)
        XCTAssertEqual(alice[0].source, "alice")
        
        XCTAssertEqual(bob.count, 1)
        XCTAssertEqual(bob[0].source, "bob")
    }
    
    func testGetAllWithCategoryFilter() async throws {
        let _ = try await repository.create(joke: JokeCreate(
            setup: "Setup 1",
            punchline: "Punchline 1",
            category: "Knock-knock",
            source: nil
        ))
        
        let _ = try await repository.create(joke: JokeCreate(
            setup: "Setup 2",
            punchline: "Punchline 2",
            category: "Puns",
            source: nil
        ))
        
        let knockKnock = try await repository.getAll(source: nil, category: "Knock-knock", limit: 100, offset: 0)
        let puns = try await repository.getAll(source: nil, category: "Puns", limit: 100, offset: 0)
        
        XCTAssertEqual(knockKnock.count, 1)
        XCTAssertEqual(knockKnock[0].category, "Knock-knock")
        
        XCTAssertEqual(puns.count, 1)
        XCTAssertEqual(puns[0].category, "Puns")
    }
    
    func testGetAllWithLimitAndOffset() async throws {
        for i in 0..<5 {
            _ = try await repository.create(joke: JokeCreate(
                setup: "Setup \(i)",
                punchline: "Punchline \(i)",
                category: nil,
                source: nil
            ))
        }
        
        let page1 = try await repository.getAll(source: nil, category: nil, limit: 2, offset: 0)
        let page2 = try await repository.getAll(source: nil, category: nil, limit: 2, offset: 2)
        let page3 = try await repository.getAll(source: nil, category: nil, limit: 2, offset: 4)
        
        XCTAssertEqual(page1.count, 2)
        XCTAssertEqual(page2.count, 2)
        XCTAssertEqual(page3.count, 1)
    }
    
    func testUpdate() async throws {
        let original = try await repository.create(joke: JokeCreate(
            setup: "Original setup",
            punchline: "Original punchline",
            category: "Original",
            source: "original"
        ))
        
        let updated = try await repository.update(id: original.id, joke: JokeCreate(
            setup: "New setup",
            punchline: "New punchline",
            category: "New",
            source: "new"
        ))
        
        XCTAssertNotNil(updated)
        XCTAssertEqual(updated?.id, original.id)
        XCTAssertEqual(updated?.setup, "New setup")
        XCTAssertEqual(updated?.punchline, "New punchline")
        XCTAssertEqual(updated?.category, "New")
        XCTAssertEqual(updated?.source, "new")
    }
    
    func testUpdateNotFound() async throws {
        let updated = try await repository.update(id: "invalid-id", joke: JokeCreate(
            setup: "New setup",
            punchline: "New punchline",
            category: nil,
            source: nil
        ))
        
        XCTAssertNil(updated)
    }
    
    func testDelete() async throws {
        let joke = try await repository.create(joke: JokeCreate(
            setup: "Setup",
            punchline: "Punchline",
            category: nil,
            source: nil
        ))
        
        let deleted = try await repository.delete(id: joke.id)
        XCTAssertTrue(deleted)
        
        let retrieved = try await repository.getById(joke.id)
        XCTAssertNil(retrieved)
    }
    
    func testDeleteNotFound() async throws {
        let deleted = try await repository.delete(id: "invalid-id")
        XCTAssertFalse(deleted)
    }
    
    func testGetRandom() async throws {
        let joke1 = try await repository.create(joke: JokeCreate(
            setup: "Setup 1",
            punchline: "Punchline 1",
            category: nil,
            source: nil
        ))
        
        let joke2 = try await repository.create(joke: JokeCreate(
            setup: "Setup 2",
            punchline: "Punchline 2",
            category: nil,
            source: nil
        ))
        
        let random = try await repository.getRandom(category: nil)
        
        XCTAssertNotNil(random)
        XCTAssertTrue([joke1.id, joke2.id].contains(random?.id))
    }
    
    func testGetRandomWithCategory() async throws {
        let joke1 = try await repository.create(joke: JokeCreate(
            setup: "Setup 1",
            punchline: "Punchline 1",
            category: "Puns",
            source: nil
        ))
        
        let _ = try await repository.create(joke: JokeCreate(
            setup: "Setup 2",
            punchline: "Punchline 2",
            category: "Knock-knock",
            source: nil
        ))
        
        let random = try await repository.getRandom(category: "Puns")
        
        XCTAssertNotNil(random)
        XCTAssertEqual(random?.id, joke1.id)
        XCTAssertEqual(random?.category, "Puns")
    }
    
    func testGetRandomEmpty() async throws {
        let random = try await repository.getRandom(category: nil)
        XCTAssertNil(random)
    }
    
    func testBumpLol() async throws {
        let joke = try await repository.create(joke: JokeCreate(
            setup: "Setup",
            punchline: "Punchline",
            category: nil,
            source: nil
        ))
        
        let counts = try await repository.bumpLol(id: joke.id)
        
        XCTAssertNotNil(counts)
        XCTAssertEqual(counts?.id, joke.id)
        XCTAssertEqual(counts?.lolCount, 1)
        XCTAssertEqual(counts?.groanCount, 0)
        
        let counts2 = try await repository.bumpLol(id: joke.id)
        XCTAssertEqual(counts2?.lolCount, 2)
    }
    
    func testBumpLolNotFound() async throws {
        let counts = try await repository.bumpLol(id: "invalid-id")
        XCTAssertNil(counts)
    }
    
    func testBumpGroan() async throws {
        let joke = try await repository.create(joke: JokeCreate(
            setup: "Setup",
            punchline: "Punchline",
            category: nil,
            source: nil
        ))
        
        let counts = try await repository.bumpGroan(id: joke.id)
        
        XCTAssertNotNil(counts)
        XCTAssertEqual(counts?.id, joke.id)
        XCTAssertEqual(counts?.lolCount, 0)
        XCTAssertEqual(counts?.groanCount, 1)
        
        let counts2 = try await repository.bumpGroan(id: joke.id)
        XCTAssertEqual(counts2?.groanCount, 2)
    }
    
    func testBumpGroanNotFound() async throws {
        let counts = try await repository.bumpGroan(id: "invalid-id")
        XCTAssertNil(counts)
    }
    
    func testBumpBothCounters() async throws {
        let joke = try await repository.create(joke: JokeCreate(
            setup: "Setup",
            punchline: "Punchline",
            category: nil,
            source: nil
        ))
        
        _ = try await repository.bumpLol(id: joke.id)
        _ = try await repository.bumpLol(id: joke.id)
        _ = try await repository.bumpGroan(id: joke.id)
        
        let retrieved = try await repository.getById(joke.id)
        
        XCTAssertEqual(retrieved?.lolCount, 2)
        XCTAssertEqual(retrieved?.groanCount, 1)
    }
}
