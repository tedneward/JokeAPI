using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using JokeApi.Repositories;
using JokeApi.Services;
using JokeApi.Models;
using System.IO;
using System.Threading.Tasks;

namespace JokeApi.Tests;

[TestClass]
public class ServiceTests
{
    private string CreateTempDbPath() => Path.Combine(Path.GetTempPath(), $"jokes_test_{Guid.NewGuid():N}.db");

    [TestMethod]
    public async Task ServiceCreatesAndFetches()
    {
        var db = CreateTempDbPath();
        var repo = new SqliteJokeRepository($"Data Source={db}");
        var svc = new JokeService(repo);
        var created = await svc.CreateAsync(new JokeCreate { Setup = "A", Punchline = "B" });
        var fetched = await svc.GetByIdAsync(created.Id);
        Assert.IsNotNull(fetched);
        Assert.AreEqual("A", fetched!.Setup);
    }
}
