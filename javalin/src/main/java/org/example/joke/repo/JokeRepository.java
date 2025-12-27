package org.example.joke.repo;

import org.example.joke.model.Joke;

import java.util.List;
import java.util.Optional;

public interface JokeRepository {
    Joke create(Joke joke);
    Optional<Joke> findById(String id);
    List<Joke> list(Optional<String> source, Optional<String> category, int limit, int offset);
    Optional<Joke> update(String id, Joke joke);
    boolean delete(String id);
    Optional<Joke> random(Optional<String> category);
    Optional<Joke> bumpLol(String id);
    Optional<Joke> bumpGroan(String id);
}
