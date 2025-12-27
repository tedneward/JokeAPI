package org.example.joke.model;

import java.util.UUID;

public record Joke(String id, String setup, String punchline, String category, String source, int lolCount, int groanCount) {
    public static Joke of(String setup, String punchline, String category, String source) {
        return new Joke(UUID.randomUUID().toString(), setup, punchline, category == null ? "" : category, source == null ? "ted" : source, 0, 0);
    }
}
