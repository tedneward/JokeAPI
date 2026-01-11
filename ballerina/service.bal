import ballerina/http;

public type Joke record {
    int id;
    string setup;
    string punchline;
    string category = "";
    string origin = "me";
    int lol_count = 0;
    int groan_count = 0;
};

int nextId = 1;
map<Joke> jokes = {};

service / on new http:Listener(8000) {

    resource function get jokes(http:Caller caller, http:Request req) returns error? {
        string? q = req.getQueryParamValue("source");
        Joke[] list = [];
        foreach [string, Joke] [_, v] in jokes.entries() {
            if q is string {
                if v.origin == q {
                    list.push(v);
                }
            } else {
                list.push(v);
            }
        }
        http:Response res = new;
        json[] out = [];
        foreach var v in list {
            json item = {
                id: v.id,
                setup: v.setup,
                punchline: v.punchline,
                category: v.category,
                "source": v.origin,
                lol_count: v.lol_count,
                groan_count: v.groan_count
            };
            out.push(item);
        }
        res.setJsonPayload(out);
        check caller->respond(res);
    }

    resource function post jokes(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        any setup = (payload is map<json>) ? (<map<json>>payload).get("setup") : ();
        any punchline = (payload is map<json>) ? (<map<json>>payload).get("punchline") : ();
        any category = (payload is map<json>) ? (<map<json>>payload).get("category") : ();
        any origin = (payload is map<json>) ? (<map<json>>payload).get("source") : ();

        string setupStr = (setup is string) ? setup : "";
        string punchlineStr = (punchline is string) ? punchline : "";
        string categoryStr = (category is string) ? category : "";
        string originStr = (origin is string) ? origin : "me";

        if setupStr == "" || punchlineStr == "" {
            http:Response bad = new;
            bad.statusCode = 400;
            bad.setJsonPayload({"error": "setup and punchline required"});
            check caller->respond(bad);
            return;
        }

        int id = nextId;
        nextId += 1;
        Joke j = {id: id, setup: setupStr, punchline: punchlineStr, category: categoryStr, origin: originStr};
        jokes[id.toString()] = j;
        http:Response res = new;
        res.statusCode = 201;
        res.setJsonPayload({id: j.id, setup: j.setup, punchline: j.punchline, category: j.category, "source": j.origin, lol_count: j.lol_count, groan_count: j.groan_count});
        check caller->respond(res);
    }

    resource function get jokes/[string id](http:Caller caller) returns error? {
        Joke? maybe = jokes[id];
        if maybe is Joke {
            http:Response res = new;
            res.setJsonPayload({id: maybe.id, setup: maybe.setup, punchline: maybe.punchline, category: maybe.category, "source": maybe.origin, lol_count: maybe.lol_count, groan_count: maybe.groan_count});
            check caller->respond(res);
            return;
        }
        http:Response notFound = new;
        notFound.statusCode = 404;
        notFound.setJsonPayload({"detail": "Not Found"});
        check caller->respond(notFound);
    }

    resource function put jokes/[string id](http:Caller caller, http:Request req) returns error? {
        Joke? existing = jokes[id];
        if existing is Joke {
            json payload = check req.getJsonPayload();
            if payload is map<json> {
                map<json> payloadMap = <map<json>>payload;
                any setup = payloadMap.get("setup");
                if setup is string {
                    existing.setup = setup;
                }
                any punchline = payloadMap.get("punchline");
                if punchline is string {
                    existing.punchline = punchline;
                }
                any category = payloadMap.get("category");
                if category is string {
                    existing.category = category;
                }
                any origin = payloadMap.get("source");
                if origin is string {
                    existing.origin = origin;
                }
            }
            jokes[id] = existing;
            http:Response res = new;
            res.setJsonPayload({id: existing.id, setup: existing.setup, punchline: existing.punchline, category: existing.category, "source": existing.origin, lol_count: existing.lol_count, groan_count: existing.groan_count});
            check caller->respond(res);
            return;
        }
        http:Response notFound = new;
        notFound.statusCode = 404;
        notFound.setJsonPayload({"detail": "Not Found"});
        check caller->respond(notFound);
    }

    resource function delete jokes/[string id](http:Caller caller) returns error? {
        if jokes.hasKey(id) {
            _ = jokes.remove(id);
            http:Response res = new;
            res.statusCode = 204;
            check caller->respond(res);
            return;
        }
        http:Response notFound = new;
        notFound.statusCode = 404;
        notFound.setJsonPayload({"detail": "Not Found"});
        check caller->respond(notFound);
    }

    resource function post jokes/[string id]/bumpLol(http:Caller caller) returns error? {
        Joke? maybe = jokes[id];
        if maybe is Joke {
            maybe.lol_count += 1;
            jokes[id] = maybe;
            http:Response res = new;
            res.setJsonPayload({lol_count: maybe.lol_count});
            check caller->respond(res);
            return;
        }
        http:Response notFound = new;
        notFound.statusCode = 404;
        notFound.setJsonPayload({"detail": "Not Found"});
        check caller->respond(notFound);
    }

    resource function post jokes/[string id]/bumpGroan(http:Caller caller) returns error? {
        Joke? maybe = jokes[id];
        if maybe is Joke {
            maybe.groan_count += 1;
            jokes[id] = maybe;
            http:Response res = new;
            res.setJsonPayload({groan_count: maybe.groan_count});
            check caller->respond(res);
            return;
        }
        http:Response notFound = new;
        notFound.statusCode = 404;
        notFound.setJsonPayload({"detail": "Not Found"});
        check caller->respond(notFound);
    }

    resource function get jokes/random(http:Caller caller, http:Request req) returns error? {
        string? q = req.getQueryParamValue("category");
        Joke[] list = [];
        foreach var [_, v] in jokes.entries() {
            if q is string {
                if v.category == q {
                    list.push(v);
                }
            } else {
                list.push(v);
            }
        }
        if list.length() == 0 {
            http:Response no = new;
            no.statusCode = 404;
            no.setJsonPayload({"detail": "No jokes"});
            check caller->respond(no);
            return;
        }
        http:Response res = new;
        var v = list[0];
        res.setJsonPayload({id: v.id, setup: v.setup, punchline: v.punchline, category: v.category, "source": v.origin, lol_count: v.lol_count, groan_count: v.groan_count});
        check caller->respond(res);
    }

    resource function get jokes/'source/[string src](http:Caller caller) returns error? {
        Joke[] list = [];
        foreach var [_, v] in jokes.entries() {
            if v.origin == src {
                list.push(v);
            }
        }
        http:Response res = new;
        json[] out2 = [];
        foreach var v in list {
            out2.push({id: v.id, setup: v.setup, punchline: v.punchline, category: v.category, "source": v.origin, lol_count: v.lol_count, groan_count: v.groan_count});
        }
        res.setJsonPayload(out2);
        check caller->respond(res);
    }

    resource function get .(http:Caller caller) returns error? {
        http:Response res = new;
        res.setJsonPayload({"status": "ok"});
        check caller->respond(res);
    }

}
