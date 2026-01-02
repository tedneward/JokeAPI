using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using JokeApi.Repositories;
using JokeApi.Models;
using System.IO;
using System.Threading.Tasks;
using System.Linq;

namespace JokeApi.Tests;

[TestClass]
public class RepositoryTests
{
    private string CreateTempDbPath()
    {
        var p = Path.Combine(Path.GetTempPath(), $"jokes_test_{Guid.NewGuid():N}.db");
        return p;
    }

    [TestMethod]
    public async Task CanCreateAndRetrieveJoke()
    {
        var db = CreateTempDbPath();
        var repo = new SqliteJokeRepository($"Data Source={db}");
        var created = await repo.CreateAsync(new JokeCreate { Setup = "Why?", Punchline = "Because.", Category = "Test", Source = "Unit" });
        Assert.IsTrue(created.Id > 0);

        var all = (await repo.GetAllAsync()).ToList();
        Assert.AreEqual(1, all.Count);
        Assert.AreEqual("Why?", all[0].Setup);
    }

    [TestMethod]
    public async Task CanIncrementCounts()
    {
        var db = CreateTempDbPath();
        var repo = new SqliteJokeRepository($"Data Source={db}");
        var created = await repo.CreateAsync(new JokeCreate { Setup = "S", Punchline = "P", Category = "C", Source = "Src" });
        var lol = await repo.IncrementLolAsync(created.Id);
        Assert.AreEqual(1, lol);
        var groan = await repo.IncrementGroanAsync(created.Id);
        Assert.AreEqual(1, groan);
    }
}
