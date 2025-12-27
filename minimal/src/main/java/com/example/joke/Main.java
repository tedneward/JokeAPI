package com.example.joke;

import io.javalin.Javalin;
import io.javalin.http.Handler;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.*;

public class Main {
    private static final ObjectMapper M = new ObjectMapper();

    public static void main(String[] args) {
        Javalin app = Javalin.create();
        app.start(8000);

        // Sample constant joke
        Joke sample = new Joke("1", "Why did the chicken cross the road?", "To get to the other side!", "Classic", "ted", 0, 0);

        app.get("/jokes", ctx -> {
            ctx.json(Collections.singletonList(sample));
        });

        app.post("/jokes", ctx -> {
            JokeCreate create = M.readValue(ctx.body(), JokeCreate.class);
            Joke created = new Joke("1", create.setup, create.punchline, Optional.ofNullable(create.category).orElse(""), Optional.ofNullable(create.source).orElse("ted"), 0, 0);
            ctx.header("Location", "/jokes/1");
            ctx.status(201).json(created);
        });

        app.get("/jokes/random", ctx -> {
            ctx.json(sample);
        });

        app.get("/jokes/{id}", ctx -> {
            String id = ctx.pathParam("id");
            if ("1".equals(id)) ctx.json(sample);
            else ctx.status(404);
        });

        app.put("/jokes/{id}", ctx -> {
            String id = ctx.pathParam("id");
            if (!"1".equals(id)) { ctx.status(404); return; }
            JokeCreate create = M.readValue(ctx.body(), JokeCreate.class);
            Joke updated = new Joke("1", create.setup, create.punchline, Optional.ofNullable(create.category).orElse(""), Optional.ofNullable(create.source).orElse("ted"), sample.lolCount, sample.groanCount);
            ctx.json(updated);
        });

        app.delete("/jokes/{id}", ctx -> {
            String id = ctx.pathParam("id");
            if ("1".equals(id)) { ctx.status(204); }
            else ctx.status(404);
        });

        app.post("/jokes/{id}/bump-lol", ctx -> {
            String id = ctx.pathParam("id");
            if (!"1".equals(id)) { ctx.status(404); return; }
            CountsResponse r = new CountsResponse("1", sample.lolCount + 1, sample.groanCount);
            ctx.json(r);
        });

        app.post("/jokes/{id}/bump-groan", ctx -> {
            String id = ctx.pathParam("id");
            if (!"1".equals(id)) { ctx.status(404); return; }
            CountsResponse r = new CountsResponse("1", sample.lolCount, sample.groanCount + 1);
            ctx.json(r);
        });
    }

    // Models
    public static class Joke {
        public String id;
        public String setup;
        public String punchline;
        public String category;
        public String source;
        public int lolCount;
        public int groanCount;

        public Joke() {}

        public Joke(String id, String setup, String punchline, String category, String source, int lolCount, int groanCount) {
            this.id = id;
            this.setup = setup;
            this.punchline = punchline;
            this.category = category;
            this.source = source;
            this.lolCount = lolCount;
            this.groanCount = groanCount;
        }
    }

    public static class JokeCreate {
        public String setup;
        public String punchline;
        public String category;
        public String source;

        public JokeCreate() {}
    }

    public static class CountsResponse {
        public String id;
        public int lolCount;
        public int groanCount;

        public CountsResponse() {}

        public CountsResponse(String id, int lolCount, int groanCount) {
            this.id = id;
            this.lolCount = lolCount;
            this.groanCount = groanCount;
        }
    }
}
