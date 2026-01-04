package com.example.routes

import io.ktor.server.routing.*
import io.ktor.server.response.*
import io.ktor.server.request.*
import com.example.services.JokeService
import com.example.models.Joke
import com.example.models.JokeCreate

fun Routing.registerJokeRoutes(service: JokeService) {
    route("/jokes") {
        get {
            call.respond(service.getAll())
        }
        get("/random") {
            val category = call.request.queryParameters["category"]
            val j = service.getRandom(category)
            if (j == null) call.respondText("Not Found", status = io.ktor.http.HttpStatusCode.NotFound)
            else call.respond(j)
        }
        get("/source/{source}") {
            val source = call.parameters["source"] ?: ""
            call.respond(service.getBySource(source))
        }
        get("/{id}") {
            val id = call.parameters["id"]?.toIntOrNull()
            if (id == null) { call.respondText("Bad Request", status = io.ktor.http.HttpStatusCode.BadRequest); return@get }
            val j = service.getById(id)
            if (j == null) call.respondText("Not Found", status = io.ktor.http.HttpStatusCode.NotFound) else call.respond(j)
        }
        post {
            val create = call.receive<JokeCreate>()
            val j = service.create(create)
            call.respond(j)
        }
        put("/{id}") {
            val id = call.parameters["id"]?.toIntOrNull() ?: run { call.respondText("Bad Request", status = io.ktor.http.HttpStatusCode.BadRequest); return@put }
            val joke = call.receive<Joke>()
            val ok = service.update(id, joke)
            if (ok) call.respondText("No Content", status = io.ktor.http.HttpStatusCode.NoContent) else call.respondText("Not Found", status = io.ktor.http.HttpStatusCode.NotFound)
        }
        delete("/{id}") {
            val id = call.parameters["id"]?.toIntOrNull() ?: run { call.respondText("Bad Request", status = io.ktor.http.HttpStatusCode.BadRequest); return@delete }
            val ok = service.delete(id)
            if (ok) call.respondText("No Content", status = io.ktor.http.HttpStatusCode.NoContent) else call.respondText("Not Found", status = io.ktor.http.HttpStatusCode.NotFound)
        }
        post("/{id}/lol") {
            val id = call.parameters["id"]?.toIntOrNull() ?: run { call.respondText("Bad Request", status = io.ktor.http.HttpStatusCode.BadRequest); return@post }
            val v = service.incrementLol(id)
            if (v < 0) call.respondText("Not Found", status = io.ktor.http.HttpStatusCode.NotFound) else call.respond(mapOf("lol" to v))
        }
        post("/{id}/groan") {
            val id = call.parameters["id"]?.toIntOrNull() ?: run { call.respondText("Bad Request", status = io.ktor.http.HttpStatusCode.BadRequest); return@post }
            val v = service.incrementGroan(id)
            if (v < 0) call.respondText("Not Found", status = io.ktor.http.HttpStatusCode.NotFound) else call.respond(mapOf("groan" to v))
        }
    }
}
