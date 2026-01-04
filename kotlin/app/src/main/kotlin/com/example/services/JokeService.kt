package com.example.services

import com.example.models.Joke
import com.example.models.JokeCreate
import com.example.repositories.JokeRepository

class JokeService(private val repo: JokeRepository) {
    suspend fun getAll(): List<Joke> = repo.getAll()
    suspend fun getById(id: Int): Joke? = repo.getById(id)
    suspend fun create(create: JokeCreate): Joke = repo.create(create)
    suspend fun update(id: Int, joke: Joke): Boolean = repo.update(id, joke)
    suspend fun delete(id: Int): Boolean = repo.delete(id)
    suspend fun getRandom(category: String?): Joke? = repo.getRandom(category)
    suspend fun getBySource(source: String): List<Joke> = repo.getBySource(source)
    suspend fun incrementLol(id: Int): Int = repo.incrementLol(id)
    suspend fun incrementGroan(id: Int): Int = repo.incrementGroan(id)
}
