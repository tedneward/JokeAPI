package com.example

import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.request.*
import io.ktor.server.routing.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.plugins.contentnegotiation.*
import com.example.repositories.SqliteJokeRepository
import com.example.services.JokeService
import com.example.routes.registerJokeRoutes

fun main() {
    val port = System.getenv("PORT")?.toIntOrNull() ?: 8000
    embeddedServer(Netty, port = port) {
        module()
    }.start(wait = true)
}

fun Application.module() {
    install(ContentNegotiation) { json() }
    val dbPath = environment.config.propertyOrNull("joke.db.path")?.getString() ?: "jokes.db"
    val repo = SqliteJokeRepository("jdbc:sqlite:$dbPath")
    val service = JokeService(repo)
    routing {
        registerJokeRoutes(service)
    }
}
