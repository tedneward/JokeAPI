using System.Data;
using Microsoft.Data.Sqlite;
using JokeApi.Models;

namespace JokeApi.Repositories;

public class SqliteJokeRepository : IJokeRepository
{
    private readonly string _connectionString;

    public SqliteJokeRepository(string connectionString)
    {
        _connectionString = connectionString;
        EnsureDatabase();
    }

    private void EnsureDatabase()
    {
        using var conn = new SqliteConnection(_connectionString);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = @"CREATE TABLE IF NOT EXISTS jokes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            setup TEXT NOT NULL,
            punchline TEXT NOT NULL,
            category TEXT NOT NULL,
            source TEXT NOT NULL,
            lol INTEGER NOT NULL DEFAULT 0,
            groan INTEGER NOT NULL DEFAULT 0
        );";
        cmd.ExecuteNonQuery();
    }

    public async Task<Joke> CreateAsync(JokeCreate create)
    {
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = @"INSERT INTO jokes (setup,punchline,category,source,lol,groan) VALUES ($s,$p,$c,$so,0,0); SELECT last_insert_rowid();";
        cmd.Parameters.AddWithValue("$s", create.Setup);
        cmd.Parameters.AddWithValue("$p", create.Punchline);
        cmd.Parameters.AddWithValue("$c", create.Category ?? string.Empty);
        cmd.Parameters.AddWithValue("$so", create.Source ?? string.Empty);
        var idObj = await cmd.ExecuteScalarAsync();
        var id = Convert.ToInt64(idObj ?? 0);
        return new Joke
        {
            Id = (int)id,
            Setup = create.Setup,
            Punchline = create.Punchline,
            Category = create.Category ?? string.Empty,
            Source = create.Source ?? string.Empty,
            LolCount = 0,
            GroanCount = 0
        };
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "DELETE FROM jokes WHERE id = $id";
        cmd.Parameters.AddWithValue("$id", id);
        var changed = await cmd.ExecuteNonQueryAsync();
        return changed > 0;
    }

    public async Task<IEnumerable<Joke>> GetAllAsync()
    {
        var list = new List<Joke>();
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id,setup,punchline,category,source,lol,groan FROM jokes";
        using var rdr = await cmd.ExecuteReaderAsync();
        while (await rdr.ReadAsync())
        {
            list.Add(ReadJoke(rdr));
        }
        return list;
    }

    public async Task<Joke?> GetByIdAsync(int id)
    {
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id,setup,punchline,category,source,lol,groan FROM jokes WHERE id = $id";
        cmd.Parameters.AddWithValue("$id", id);
        using var rdr = await cmd.ExecuteReaderAsync();
        if (await rdr.ReadAsync()) return ReadJoke(rdr);
        return null;
    }

    public async Task<Joke?> GetRandomAsync(string? category = null)
    {
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        if (string.IsNullOrEmpty(category))
        {
            cmd.CommandText = "SELECT id,setup,punchline,category,source,lol,groan FROM jokes ORDER BY RANDOM() LIMIT 1";
        }
        else
        {
            cmd.CommandText = "SELECT id,setup,punchline,category,source,lol,groan FROM jokes WHERE category = $c ORDER BY RANDOM() LIMIT 1";
            cmd.Parameters.AddWithValue("$c", category);
        }
        using var rdr = await cmd.ExecuteReaderAsync();
        if (await rdr.ReadAsync()) return ReadJoke(rdr);
        return null;
    }

    public async Task<IEnumerable<Joke>> GetBySourceAsync(string source)
    {
        var list = new List<Joke>();
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id,setup,punchline,category,source,lol,groan FROM jokes WHERE source = $s";
        cmd.Parameters.AddWithValue("$s", source);
        using var rdr = await cmd.ExecuteReaderAsync();
        while (await rdr.ReadAsync()) list.Add(ReadJoke(rdr));
        return list;
    }

    public async Task<int> IncrementLolAsync(int id)
    {
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var tx = conn.BeginTransaction();
        using var cmd = conn.CreateCommand();
        cmd.Transaction = tx;
        cmd.CommandText = "UPDATE jokes SET lol = lol + 1 WHERE id = $id";
        cmd.Parameters.AddWithValue("$id", id);
        var changed = await cmd.ExecuteNonQueryAsync();
        if (changed == 0) { await tx.RollbackAsync(); return -1; }
        cmd.CommandText = "SELECT lol FROM jokes WHERE id = $id";
        var valObj = await cmd.ExecuteScalarAsync();
        var val = Convert.ToInt64(valObj ?? 0);
        await tx.CommitAsync();
        return (int)val;
    }

    public async Task<int> IncrementGroanAsync(int id)
    {
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var tx = conn.BeginTransaction();
        using var cmd = conn.CreateCommand();
        cmd.Transaction = tx;
        cmd.CommandText = "UPDATE jokes SET groan = groan + 1 WHERE id = $id";
        cmd.Parameters.AddWithValue("$id", id);
        var changed = await cmd.ExecuteNonQueryAsync();
        if (changed == 0) { await tx.RollbackAsync(); return -1; }
        cmd.CommandText = "SELECT groan FROM jokes WHERE id = $id";
        var valObj = await cmd.ExecuteScalarAsync();
        var val = Convert.ToInt64(valObj ?? 0);
        await tx.CommitAsync();
        return (int)val;
    }

    public async Task<bool> UpdateAsync(int id, Joke joke)
    {
        using var conn = new SqliteConnection(_connectionString);
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = @"UPDATE jokes SET setup=$s,punchline=$p,category=$c,source=$so,lol=$l,groan=$g WHERE id=$id";
        cmd.Parameters.AddWithValue("$s", joke.Setup);
        cmd.Parameters.AddWithValue("$p", joke.Punchline);
        cmd.Parameters.AddWithValue("$c", joke.Category);
        cmd.Parameters.AddWithValue("$so", joke.Source);
        cmd.Parameters.AddWithValue("$l", joke.LolCount);
        cmd.Parameters.AddWithValue("$g", joke.GroanCount);
        cmd.Parameters.AddWithValue("$id", id);
        var changed = await cmd.ExecuteNonQueryAsync();
        return changed > 0;
    }

    private static Joke ReadJoke(SqliteDataReader rdr)
    {
        return new Joke
        {
            Id = rdr.GetInt32(0),
            Setup = rdr.GetString(1),
            Punchline = rdr.GetString(2),
            Category = rdr.GetString(3),
            Source = rdr.GetString(4),
            LolCount = rdr.GetInt32(5),
            GroanCount = rdr.GetInt32(6)
        };
    }
}
