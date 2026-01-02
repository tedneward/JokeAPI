using JokeApi.Repositories;
using JokeApi.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetValue<string>("Sqlite:ConnectionString")
                       ?? Path.Combine(builder.Environment.ContentRootPath, "jokes.db");

builder.Services.AddSingleton<IJokeRepository>(sp => new SqliteJokeRepository($"Data Source={connectionString}"));
builder.Services.AddScoped<JokeService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseRouting();
app.UseAuthorization();
app.MapControllers();

app.Run();
