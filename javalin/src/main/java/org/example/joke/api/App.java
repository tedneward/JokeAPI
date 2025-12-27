package org.example.joke.api;

import io.javalin.Javalin;
import org.example.joke.model.Joke;
import org.example.joke.model.JokeCreate;
import org.example.joke.repo.SqliteJokeRepository;
import org.example.joke.service.JokeService;

import java.util.Optional;

public class App {
    public static void main(String[] args) {
        String db = System.getProperty("jokes.db", "jokes.db");
        SqliteJokeRepository repo = new SqliteJokeRepository("jdbc:sqlite:" + db);
        JokeService svc = new JokeService(repo);

        Javalin app = Javalin.create();
        app.before(ctx -> ctx.contentType("application/json"));
        app.start(8000);

        app.get("/jokes", ctx -> {
            Optional<String> source = Optional.ofNullable(ctx.queryParam("source"));
            Optional<String> category = Optional.ofNullable(ctx.queryParam("category"));
            int limit = ctx.queryParamAsClass("limit", Integer.class).getOrDefault(100);
            int offset = ctx.queryParamAsClass("offset", Integer.class).getOrDefault(0);
            ctx.json(svc.list(source, category, limit, offset));
        });

        app.post("/jokes", ctx -> {
            JokeCreate create = ctx.bodyAsClass(JokeCreate.class);
            Joke created = svc.create(create);
            ctx.header("Location", "/jokes/" + created.id());
            ctx.status(201).json(created);
        });

        app.get("/jokes/random", ctx -> {
            Optional<String> category = Optional.ofNullable(ctx.queryParam("category"));
            svc.random(category).ifPresentOrElse(ctx::json, () -> ctx.status(404));
        });

        app.get("/jokes/{id}", ctx -> {
            String id = ctx.pathParam("id");
            svc.get(id).ifPresentOrElse(ctx::json, () -> ctx.status(404));
        });

        app.put("/jokes/{id}", ctx -> {
            String id = ctx.pathParam("id");
            JokeCreate create = ctx.bodyAsClass(JokeCreate.class);
            svc.update(id, create).ifPresentOrElse(ctx::json, () -> ctx.status(404));
        });

        app.delete("/jokes/{id}", ctx -> {
            String id = ctx.pathParam("id");
            if (svc.delete(id)) ctx.status(204); else ctx.status(404);
        });

        app.post("/jokes/{id}/bump-lol", ctx -> {
            String id = ctx.pathParam("id");
            svc.bumpLol(id).ifPresentOrElse(ctx::json, () -> ctx.status(404));
        });

        app.post("/jokes/{id}/bump-groan", ctx -> {
            String id = ctx.pathParam("id");
            svc.bumpGroan(id).ifPresentOrElse(ctx::json, () -> ctx.status(404));
        });
    }
}
