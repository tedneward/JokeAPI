import Vapor

func routes(_ app: Application) throws {
    app.get("jokes") { req async throws -> [Joke] in
        let repository = req.application.jokeRepository
        let source = req.query[String.self, at: "source"]
        let category = req.query[String.self, at: "category"]
        let limit = req.query[Int.self, at: "limit"] ?? 100
        let offset = req.query[Int.self, at: "offset"] ?? 0
        
        return try await repository.getAll(source: source, category: category, limit: limit, offset: offset)
    }
    
    app.post("jokes") { req async throws -> Response in
        let repository = req.application.jokeRepository
        let jokeCreate = try req.content.decode(JokeCreate.self)
        let joke = try await repository.create(joke: jokeCreate)
        
        var response = Response(status: .created)
        response.headers.contentType = .json
        response.headers.add(name: "Location", value: "/jokes/\(joke.id)")
        try response.content.encode(joke, using: JSONEncoder())
        return response
    }
    
    app.get("jokes", "random") { req async throws -> Joke in
        let repository = req.application.jokeRepository
        let category = req.query[String.self, at: "category"]
        
        guard let joke = try await repository.getRandom(category: category) else {
            throw Abort(.notFound)
        }
        return joke
    }
    
    app.get("jokes", ":id") { req async throws -> Joke in
        let repository = req.application.jokeRepository
        guard let id = req.parameters.get("id") else {
            throw Abort(.notFound)
        }
        
        guard let joke = try await repository.getById(id) else {
            throw Abort(.notFound)
        }
        return joke
    }
    
    app.put("jokes", ":id") { req async throws -> Joke in
        let repository = req.application.jokeRepository
        guard let id = req.parameters.get("id") else {
            throw Abort(.notFound)
        }
        
        let jokeCreate = try req.content.decode(JokeCreate.self)
        guard let joke = try await repository.update(id: id, joke: jokeCreate) else {
            throw Abort(.notFound)
        }
        return joke
    }
    
    app.delete("jokes", ":id") { req async throws -> HTTPStatus in
        let repository = req.application.jokeRepository
        guard let id = req.parameters.get("id") else {
            throw Abort(.notFound)
        }
        
        guard try await repository.delete(id: id) else {
            throw Abort(.notFound)
        }
        return .noContent
    }
    
    app.post("jokes", ":id", "bump-lol") { req async throws -> CountsResponse in
        let repository = req.application.jokeRepository
        guard let id = req.parameters.get("id") else {
            throw Abort(.notFound)
        }
        
        guard let counts = try await repository.bumpLol(id: id) else {
            throw Abort(.notFound)
        }
        return counts
    }
    
    app.post("jokes", ":id", "bump-groan") { req async throws -> CountsResponse in
        let repository = req.application.jokeRepository
        guard let id = req.parameters.get("id") else {
            throw Abort(.notFound)
        }
        
        guard let counts = try await repository.bumpGroan(id: id) else {
            throw Abort(.notFound)
        }
        return counts
    }
}
