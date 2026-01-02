using Microsoft.AspNetCore.Mvc;
using JokeApi.Models;
using JokeApi.Services;

namespace JokeApi.Controllers;

[ApiController]
[Route("jokes")]
public class JokesController : ControllerBase
{
    private readonly JokeService _service;

    public JokesController(JokeService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var all = await _service.GetAllAsync();
        return Ok(all);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
    {
        var j = await _service.GetByIdAsync(id);
        if (j is null) return NotFound();
        return Ok(j);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] JokeCreate create)
    {
        var j = await _service.CreateAsync(create);
        return CreatedAtAction(nameof(Get), new { id = j.Id }, j);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] Joke j)
    {
        var ok = await _service.UpdateAsync(id, j);
        if (!ok) return NotFound();
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var ok = await _service.DeleteAsync(id);
        if (!ok) return NotFound();
        return NoContent();
    }

    [HttpGet("random")]
    public async Task<IActionResult> Random([FromQuery] string? category)
    {
        var j = await _service.GetRandomAsync(category);
        if (j is null) return NotFound();
        return Ok(j);
    }

    [HttpGet("source/{source}")]
    public async Task<IActionResult> BySource(string source)
    {
        var list = await _service.GetBySourceAsync(source);
        return Ok(list);
    }

    [HttpPost("{id:int}/lol")]
    public async Task<IActionResult> BumpLol(int id)
    {
        var v = await _service.IncrementLolAsync(id);
        if (v < 0) return NotFound();
        return Ok(new { lol = v });
    }

    [HttpPost("{id:int}/groan")]
    public async Task<IActionResult> BumpGroan(int id)
    {
        var v = await _service.IncrementGroanAsync(id);
        if (v < 0) return NotFound();
        return Ok(new { groan = v });
    }
}
