import Vapor

extension Application {
    struct JokeRepositoryKey: StorageKey {
        typealias Value = JokeRepository
    }
    
    var jokeRepository: JokeRepository {
        get {
            storage[JokeRepositoryKey.self] ?? FluentJokeRepository(db)
        }
        set {
            storage[JokeRepositoryKey.self] = newValue
        }
    }
}
