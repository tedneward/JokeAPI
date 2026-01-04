package com.example.repositories

import com.example.models.Joke
import com.example.models.JokeCreate
import java.sql.DriverManager

class SqliteJokeRepository(private val jdbcUrl: String) : JokeRepository {
    init {
        ensureDatabase()
    }

    private fun ensureDatabase() {
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.createStatement().use { st ->
                st.execute(
                    """
                    CREATE TABLE IF NOT EXISTS jokes (
                      id INTEGER PRIMARY KEY AUTOINCREMENT,
                      setup TEXT NOT NULL,
                      punchline TEXT NOT NULL,
                      category TEXT NOT NULL,
                      source TEXT NOT NULL,
                      lol INTEGER NOT NULL DEFAULT 0,
                      groan INTEGER NOT NULL DEFAULT 0
                    );
                    """
                )
            }
        }
    }

    override suspend fun getAll(): List<Joke> = queryList("SELECT id,setup,punchline,category,source,lol,groan FROM jokes")

    override suspend fun getById(id: Int): Joke? = querySingle("SELECT id,setup,punchline,category,source,lol,groan FROM jokes WHERE id = ?", listOf(id))

    override suspend fun create(create: JokeCreate): Joke {
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.prepareStatement(
                "INSERT INTO jokes(setup,punchline,category,source,lol,groan) VALUES(?,?,?,?,0,0)",
                java.sql.Statement.RETURN_GENERATED_KEYS
            ).use { ps ->
                ps.setString(1, create.setup)
                ps.setString(2, create.punchline)
                ps.setString(3, create.category)
                ps.setString(4, create.source)
                ps.executeUpdate()
                val rs = ps.generatedKeys
                val id = if (rs.next()) rs.getInt(1) else 0
                return Joke(id, create.setup, create.punchline, create.category, create.source, 0, 0)
            }
        }
    }

    override suspend fun update(id: Int, joke: Joke): Boolean {
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.prepareStatement("UPDATE jokes SET setup=?,punchline=?,category=?,source=?,lol=?,groan=? WHERE id=?").use { ps ->
                ps.setString(1, joke.setup)
                ps.setString(2, joke.punchline)
                ps.setString(3, joke.category)
                ps.setString(4, joke.source)
                ps.setInt(5, joke.lolCount)
                ps.setInt(6, joke.groanCount)
                ps.setInt(7, id)
                return ps.executeUpdate() > 0
            }
        }
    }

    override suspend fun delete(id: Int): Boolean {
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.prepareStatement("DELETE FROM jokes WHERE id=?").use { ps ->
                ps.setInt(1, id)
                return ps.executeUpdate() > 0
            }
        }
    }

    override suspend fun getRandom(category: String?): Joke? {
        return if (category.isNullOrEmpty()) {
            querySingle("SELECT id,setup,punchline,category,source,lol,groan FROM jokes ORDER BY RANDOM() LIMIT 1")
        } else {
            querySingle("SELECT id,setup,punchline,category,source,lol,groan FROM jokes WHERE category = ? ORDER BY RANDOM() LIMIT 1", listOf(category))
        }
    }

    override suspend fun getBySource(source: String): List<Joke> = queryList("SELECT id,setup,punchline,category,source,lol,groan FROM jokes WHERE source = ?", listOf(source))

    override suspend fun incrementLol(id: Int): Int {
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.autoCommit = false
            conn.prepareStatement("UPDATE jokes SET lol = lol + 1 WHERE id = ?").use { ps ->
                ps.setInt(1, id)
                val changed = ps.executeUpdate()
                if (changed == 0) { conn.rollback(); return -1 }
            }
            conn.prepareStatement("SELECT lol FROM jokes WHERE id = ?").use { ps ->
                ps.setInt(1, id)
                ps.executeQuery().use { rs -> if (rs.next()) { val v = rs.getInt(1); conn.commit(); return v } }
            }
            conn.rollback()
            return -1
        }
    }

    override suspend fun incrementGroan(id: Int): Int {
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.autoCommit = false
            conn.prepareStatement("UPDATE jokes SET groan = groan + 1 WHERE id = ?").use { ps ->
                ps.setInt(1, id)
                val changed = ps.executeUpdate()
                if (changed == 0) { conn.rollback(); return -1 }
            }
            conn.prepareStatement("SELECT groan FROM jokes WHERE id = ?").use { ps ->
                ps.setInt(1, id)
                ps.executeQuery().use { rs -> if (rs.next()) { val v = rs.getInt(1); conn.commit(); return v } }
            }
            conn.rollback()
            return -1
        }
    }

    private fun queryList(sql: String, params: List<Any> = emptyList()): List<Joke> {
        val out = mutableListOf<Joke>()
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.prepareStatement(sql).use { ps ->
                params.forEachIndexed { idx, v -> ps.setObject(idx + 1, v) }
                ps.executeQuery().use { rs ->
                    while (rs.next()) {
                        out.add(Joke(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getInt(6), rs.getInt(7)))
                    }
                }
            }
        }
        return out
    }

    private fun querySingle(sql: String, params: List<Any> = emptyList()): Joke? {
        DriverManager.getConnection(jdbcUrl).use { conn ->
            conn.prepareStatement(sql).use { ps ->
                params.forEachIndexed { idx, v -> ps.setObject(idx + 1, v) }
                ps.executeQuery().use { rs ->
                    if (rs.next()) return Joke(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5), rs.getInt(6), rs.getInt(7))
                }
            }
        }
        return null
    }
}
