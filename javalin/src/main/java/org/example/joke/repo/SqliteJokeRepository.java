package org.example.joke.repo;

import org.example.joke.model.Joke;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class SqliteJokeRepository implements JokeRepository {
    private final String url;

    public SqliteJokeRepository(String jdbcUrl) {
        this.url = jdbcUrl;
        try (Connection c = connect()) {
            try (Statement s = c.createStatement()) {
                s.executeUpdate("""
                        CREATE TABLE IF NOT EXISTS jokes (
                          id TEXT PRIMARY KEY,
                          setup TEXT NOT NULL,
                          punchline TEXT NOT NULL,
                          category TEXT NOT NULL,
                          source TEXT NOT NULL,
                          lol_count INTEGER NOT NULL,
                          groan_count INTEGER NOT NULL
                        )
                        """);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private Connection connect() throws SQLException {
        return DriverManager.getConnection(url);
    }

    @Override
    public Joke create(Joke joke) {
        String sql = "INSERT INTO jokes(id,setup,punchline,category,source,lol_count,groan_count) VALUES(?,?,?,?,?,?,?)";
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, joke.id());
            ps.setString(2, joke.setup());
            ps.setString(3, joke.punchline());
            ps.setString(4, joke.category());
            ps.setString(5, joke.source());
            ps.setInt(6, joke.lolCount());
            ps.setInt(7, joke.groanCount());
            ps.executeUpdate();
            return joke;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Optional<Joke> findById(String id) {
        String sql = "SELECT * FROM jokes WHERE id = ?";
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(rowToJoke(rs));
                return Optional.empty();
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public List<Joke> list(Optional<String> source, Optional<String> category, int limit, int offset) {
        StringBuilder sb = new StringBuilder("SELECT * FROM jokes");
        List<String> clauses = new ArrayList<>();
        if (source.isPresent()) clauses.add("source = ?");
        if (category.isPresent()) clauses.add("category = ?");
        if (!clauses.isEmpty()) sb.append(" WHERE ").append(String.join(" AND ", clauses));
        sb.append(" LIMIT ? OFFSET ?");
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sb.toString())) {
            int idx = 1;
            if (source.isPresent()) ps.setString(idx++, source.get());
            if (category.isPresent()) ps.setString(idx++, category.get());
            ps.setInt(idx++, limit);
            ps.setInt(idx, offset);
            try (ResultSet rs = ps.executeQuery()) {
                List<Joke> out = new ArrayList<>();
                while (rs.next()) out.add(rowToJoke(rs));
                return out;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Optional<Joke> update(String id, Joke joke) {
        String sql = "UPDATE jokes SET setup=?,punchline=?,category=?,source=?,lol_count=?,groan_count=? WHERE id=?";
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, joke.setup());
            ps.setString(2, joke.punchline());
            ps.setString(3, joke.category());
            ps.setString(4, joke.source());
            ps.setInt(5, joke.lolCount());
            ps.setInt(6, joke.groanCount());
            ps.setString(7, id);
            int updated = ps.executeUpdate();
            return updated == 1 ? Optional.of(joke) : Optional.empty();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public boolean delete(String id) {
        String sql = "DELETE FROM jokes WHERE id = ?";
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Optional<Joke> random(Optional<String> category) {
        String sql = category.isPresent() ? "SELECT * FROM jokes WHERE category = ? ORDER BY RANDOM() LIMIT 1" : "SELECT * FROM jokes ORDER BY RANDOM() LIMIT 1";
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            if (category.isPresent()) ps.setString(1, category.get());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(rowToJoke(rs));
                return Optional.empty();
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Optional<Joke> bumpLol(String id) {
        String sql = "UPDATE jokes SET lol_count = lol_count + 1 WHERE id = ?";
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            int updated = ps.executeUpdate();
            if (updated == 1) return findById(id);
            return Optional.empty();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public Optional<Joke> bumpGroan(String id) {
        String sql = "UPDATE jokes SET groan_count = groan_count + 1 WHERE id = ?";
        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            int updated = ps.executeUpdate();
            if (updated == 1) return findById(id);
            return Optional.empty();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private Joke rowToJoke(ResultSet rs) throws SQLException {
        return new Joke(rs.getString("id"), rs.getString("setup"), rs.getString("punchline"), rs.getString("category"), rs.getString("source"), rs.getInt("lol_count"), rs.getInt("groan_count"));
    }
}
