package com.example.models

@kotlinx.serialization.Serializable
data class Joke(
    val id: Int = 0,
    val setup: String = "",
    val punchline: String = "",
    val category: String = "",
    val source: String = "",
    val lolCount: Int = 0,
    val groanCount: Int = 0
)
