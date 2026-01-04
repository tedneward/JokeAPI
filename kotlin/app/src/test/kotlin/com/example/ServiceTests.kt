package com.example

import kotlin.test.*
import com.example.repositories.SqliteJokeRepository
import com.example.services.JokeService
import com.example.models.JokeCreate
import kotlinx.coroutines.runBlocking
import java.io.File

class ServiceTests {
    private fun tempDb(): String = File.createTempFile("jokes_test_", ".db").apply { delete() }.absolutePath

    @Test
    fun serviceCreateAndFetch() = runBlocking {
        val db = tempDb()
        val repo = SqliteJokeRepository("jdbc:sqlite:$db")
        val svc = JokeService(repo)
        val created = svc.create(JokeCreate(setup = "A", punchline = "B"))
        val fetched = svc.getById(created.id)
        assertNotNull(fetched)
        assertEquals("A", fetched!!.setup)
    }
}
