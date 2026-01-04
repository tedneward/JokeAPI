package com.example.models

@kotlinx.serialization.Serializable
data class JokeCreate(
    val setup: String = "",
    val punchline: String = "",
    val category: String = "",
    val source: String = ""
)
