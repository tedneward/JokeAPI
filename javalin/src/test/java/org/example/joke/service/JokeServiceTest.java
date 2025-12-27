package org.example.joke.service;

import org.example.joke.model.Joke;
import org.example.joke.model.JokeCreate;
import org.example.joke.repo.SqliteJokeRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;

public class JokeServiceTest {
    private Path dbfile;
    private JokeService svc;

    @BeforeEach
    public void setup() throws Exception {
        dbfile = Files.createTempFile("jokes-test-", ".db");
        SqliteJokeRepository repo = new SqliteJokeRepository("jdbc:sqlite:" + dbfile.toAbsolutePath());
        svc = new JokeService(repo);
    }

    @AfterEach
    public void teardown() throws Exception {
        Files.deleteIfExists(dbfile);
    }

    @Test
    public void createAndGet() {
        JokeCreate create = new JokeCreate("s","p","cat","me");
        Joke j = svc.create(create);
        Optional<Joke> got = svc.get(j.id());
        Assertions.assertTrue(got.isPresent());
        Assertions.assertEquals("s", got.get().setup());
    }

    @Test
    public void bumpCounts() {
        JokeCreate create = new JokeCreate("s2","p2","cat","me");
        Joke j = svc.create(create);
        svc.bumpLol(j.id());
        svc.bumpGroan(j.id());
        Optional<Joke> got = svc.get(j.id());
        Assertions.assertTrue(got.isPresent());
        Assertions.assertEquals(1, got.get().lolCount());
        Assertions.assertEquals(1, got.get().groanCount());
    }
}
