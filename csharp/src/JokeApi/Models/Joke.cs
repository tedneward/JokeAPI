namespace JokeApi.Models;

public class Joke
{
    public int Id { get; set; }
    public string Setup { get; set; } = string.Empty;
    public string Punchline { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Source { get; set; } = string.Empty;
    public int LolCount { get; set; }
    public int GroanCount { get; set; }
}
