package org.example.joke.repo;

import org.example.joke.model.Joke;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;

public class SqliteJokeRepositoryTest {
    private Path dbfile;
    private SqliteJokeRepository repo;

    @BeforeEach
    public void setup() throws Exception {
        dbfile = Files.createTempFile("jokes-repo-", ".db");
        repo = new SqliteJokeRepository("jdbc:sqlite:" + dbfile.toAbsolutePath());
    }

    @AfterEach
    public void teardown() throws Exception {
        Files.deleteIfExists(dbfile);
    }

    @Test
    public void createFindDelete() {
        Joke j = Joke.of("s","p","cat","me");
        repo.create(j);
        Optional<Joke> got = repo.findById(j.id());
        Assertions.assertTrue(got.isPresent());
        Assertions.assertEquals(j.setup(), got.get().setup());
        Assertions.assertTrue(repo.delete(j.id()));
        Assertions.assertTrue(repo.findById(j.id()).isEmpty());
    }
}
