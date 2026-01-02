namespace JokeApi.Models;

public class JokeCreate
{
    public string Setup { get; set; } = string.Empty;
    public string Punchline { get; set; } = string.Empty;
    public string? Category { get; set; }
    public string? Source { get; set; }
}
