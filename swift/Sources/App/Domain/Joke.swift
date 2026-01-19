import Foundation
import Vapor

struct Joke: Codable, Content {
    let id: String
    let setup: String
    let punchline: String
    let category: String
    let source: String
    let lolCount: Int
    let groanCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case setup
        case punchline
        case category
        case source
        case lolCount
        case groanCount
    }
}

struct JokeCreate: Codable, Content {
    let setup: String?
    let punchline: String?
    let category: String?
    let source: String?
    
    enum CodingKeys: String, CodingKey {
        case setup
        case punchline
        case category
        case source
    }
}

struct CountsResponse: Codable, Content {
    let id: String
    let lolCount: Int
    let groanCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case lolCount
        case groanCount
    }
}
