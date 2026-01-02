using JokeApi.Models;
using JokeApi.Repositories;

namespace JokeApi.Services;

public class JokeService
{
    private readonly IJokeRepository _repo;

    public JokeService(IJokeRepository repo)
    {
        _repo = repo;
    }

    public Task<IEnumerable<Joke>> GetAllAsync() => _repo.GetAllAsync();
    public Task<Joke?> GetByIdAsync(int id) => _repo.GetByIdAsync(id);
    public Task<Joke> CreateAsync(JokeCreate c) => _repo.CreateAsync(c);
    public Task<bool> UpdateAsync(int id, Joke j) => _repo.UpdateAsync(id, j);
    public Task<bool> DeleteAsync(int id) => _repo.DeleteAsync(id);
    public Task<Joke?> GetRandomAsync(string? category) => _repo.GetRandomAsync(category);
    public Task<IEnumerable<Joke>> GetBySourceAsync(string source) => _repo.GetBySourceAsync(source);
    public Task<int> IncrementLolAsync(int id) => _repo.IncrementLolAsync(id);
    public Task<int> IncrementGroanAsync(int id) => _repo.IncrementGroanAsync(id);
}
