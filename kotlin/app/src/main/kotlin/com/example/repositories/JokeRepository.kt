package com.example.repositories

import com.example.models.Joke
import com.example.models.JokeCreate

interface JokeRepository {
    suspend fun getAll(): List<Joke>
    suspend fun getById(id: Int): Joke?
    suspend fun create(create: JokeCreate): Joke
    suspend fun update(id: Int, joke: Joke): Boolean
    suspend fun delete(id: Int): Boolean
    suspend fun getRandom(category: String? = null): Joke?
    suspend fun getBySource(source: String): List<Joke>
    suspend fun incrementLol(id: Int): Int
    suspend fun incrementGroan(id: Int): Int
}
