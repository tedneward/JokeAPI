import Vapor

let app = try await Application.make()
try await configure(app)
try await app.execute()

