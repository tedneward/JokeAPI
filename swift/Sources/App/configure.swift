import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) async throws {
    // Configure server to listen on all interfaces
    app.http.server.configuration.address = .hostname("0.0.0.0", port: 8000)
    
    // Configure database
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    
    // Configure migrations
    app.migrations.add(CreateJokeMigration())
    
    // Run migrations
    try await app.autoMigrate()
    
    // Register routes
    try routes(app)
}
