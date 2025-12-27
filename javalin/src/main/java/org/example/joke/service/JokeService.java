package org.example.joke.service;

import org.example.joke.model.Joke;
import org.example.joke.model.JokeCreate;
import org.example.joke.repo.JokeRepository;

import java.util.List;
import java.util.Optional;

public class JokeService {
    private final JokeRepository repo;

    public JokeService(JokeRepository repo) {
        this.repo = repo;
    }

    public Joke create(JokeCreate create) {
        Joke j = Joke.of(create.setup(), create.punchline(), create.category(), create.source());
        return repo.create(j);
    }

    public Optional<Joke> get(String id) { return repo.findById(id); }

    public List<Joke> list(Optional<String> source, Optional<String> category, int limit, int offset) {
        return repo.list(source, category, limit, offset);
    }

    public Optional<Joke> update(String id, JokeCreate create) {
        return repo.findById(id).flatMap(old -> {
            Joke updated = new Joke(id, create.setup(), create.punchline(), create.category() == null ? "" : create.category(), create.source() == null ? "ted" : create.source(), old.lolCount(), old.groanCount());
            return repo.update(id, updated);
        });
    }

    public boolean delete(String id) { return repo.delete(id); }

    public Optional<Joke> random(Optional<String> category) { return repo.random(category); }

    public Optional<Joke> bumpLol(String id) { return repo.bumpLol(id); }

    public Optional<Joke> bumpGroan(String id) { return repo.bumpGroan(id); }
}
