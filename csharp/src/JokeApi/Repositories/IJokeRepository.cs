using JokeApi.Models;

namespace JokeApi.Repositories;

public interface IJokeRepository
{
    Task<IEnumerable<Joke>> GetAllAsync();
    Task<Joke?> GetByIdAsync(int id);
    Task<Joke> CreateAsync(JokeCreate create);
    Task<bool> UpdateAsync(int id, Joke joke);
    Task<bool> DeleteAsync(int id);
    Task<Joke?> GetRandomAsync(string? category = null);
    Task<IEnumerable<Joke>> GetBySourceAsync(string source);
    Task<int> IncrementLolAsync(int id);
    Task<int> IncrementGroanAsync(int id);
}
