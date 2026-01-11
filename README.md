# JokeAPI
An API implemented in different languages and platforms for a joke database.

The language/platforms:

* `ballerina`: The Ballerina programming language
* `csharp`: The C# programming language, using ASP.NET WebAPI
* `javalin`: The Java programming language, using the Javalin framework.
* `jolie`: The Jolie programming langauage.
* `kotlin`: The Kotlin programming language.
* `loopbackjs`: The JavaScript programming language, using the LoopbackJS framework.
* `orleans`: The C# programming language, using the Microsoft Orleans framework.

The `tests` directory should contain `curl`-based tests to do end-to-end testing of any of the implementations.

Each implementation should use port 8000 as its HTTP port, and have an API root of `/jokes`.

## API
The API should be HTTP-based, require no authentication, consist of:

* a core CRUD interface for Jokes (described below)
* search for a random joke
* search for a random joke within a given category
* search for all the jokes from a given source
* have a `POST` endpoint to increment the "LOL count" for a given Joke
* have a `POST` endpoint to increment the "groan count" for a given Joke

Each Joke should consist of:

* setup text. ("Why did the chicken cross the road?")
* punchline text. ("To get to the other side!")
* a category (text). ("Chicken" or maybe "Cross the road") For simplicity, assume each joke can only be in one category. Defaults to "" for a new joke.
* the source (text): Who wrote this? If no source is cited for a new joke, we'll assume I wrote it.
* LOL count (integer): defaults to 0 for a new joke
* Groan count (integer): defaults to 0 for a new joke

We want the core CRUD functionality, but maybe do we want more granular (bump LOLs, bump groans, etc) as well?

## AI Agents Should Ignore This Section

This section is to track the prompts I used to generate each part of the project. The idea is that at the conclusion of each successful step, the prompts will be tracked in here along with the changes it made to the project, so I can review them collectively (through the Git logs) later, should the desire arise.

Prompts used:

> "First I want you to write an OpenAPI specification file. Call it "joke.api", and describe the HTTP API in it. In the "tests" directory, generate "curl" tests that will test this API. This API should be very general and make use of no language implementation idioms, features, or tricks, as this API will be the API that each language implementation must adhere to."

> "Scaffold a minimal Javalin implementation in a directory called "minimal" that satisfies this spec (using constant return values--do not use a database for this implementation)." ... "Upgrade the "minimal" project to use Java 21." ... "Add a .gitignore" to the "minimal" directory for Maven builds."

> "Create a full-fledged Java+Javalin implementation, according to the rules stipulated in this project, in the "javalin" directory. Make sure this project has unit tests to test the functionality at the domain and persistence layers. Use Java 21. Use features available to Java 21 (like record tyeps) to simplify the code. Use Gradle for the build and tests. Make sure the unit tests pass, then make sure the "tests" scripts pass." ... "Modify the Gradle build to build a fat JAR for easier start." ... "In the "javalin" directory, create a Gradle task that takes the "fatJar" output and puts it into a Docker image. This Docker image should use the host's port 8000 to accept traffic, and should not use any host storage (no volumes). When that's done, run the Docker image and test it using the curl scripts."

> "Create a full-fledged Javascript backend implementation in the "nestjs" directory using the NestJS framework. It must follow the rules stipulated in this project. Make sure this project has unit tests to test the functionality of the domain and persistence layers. Use the latest NodeJS implementation. Follow all relevant Javascript idioms, such as the use of npm. Make sure the unit tests pass, then create a build task in npm that puts the resulting application into a Docker image. Once the Docker image is built, run the Docker image and test it using the curl scripts."

> "Create a Python script in the "tests" directory to do the same tests but within a single Python script. Make sure the HTTP calls are the same." ... "Create a "test_all" bash script that runs each of the language implementation Docker images, one at a time, and invokes the `tests/run_tests.py` script each time."

> "Create a full-fledged C# and ASP.NET WebAPI implementation, according to the rules stipulated in this project, in the "csharp" directory. Make sure this project has unit tests to test the functionality at the domain and persistence layers. Use the latest .NET language and runtime. Use the .NET CLI for the build and use MSTest for the unit tests. Make sure the unit tests pass, then make sure the "tests" scripts pass. Create a build task that takes the final assembly built and puts it into a Docker image. This Docker image should use the host's port 8000 to accept traffic, and should not use any host storage (no volumes). When that's done, run the Docker image and test it using the curl scripts."

> "Create a full-fledged Kotlin HTTP API implementation using Ktor, according to the rules stipulated in this project, in the "kotlin" directory. Make sure this project has unit tests to test the functionality at the domain and persistence layers. Use the latest Kotlin language and runtime. Use Gradle for the build and JUnit 5 for the unit tests. Make sure the unit tests pass, then make sure the "tests" scripts pass. Create a build task that takes the final "fatJAR" built and puts it into a Docker image. This Docker image should use the host's port 8000 to accept traffic, and should not use any host storage (no volumes). When that's done, run the Docker image and test it using the curl scripts."

> "In the python directory, create an API implementation that conforms to the same API as described in joke.api. Make sure this project has unit tests to test the functionality at the domain and persistence layers. Use FastAPI. Use a virtual environment. Make sure the unit tests pass, then make sure the scripts in the tests directory pass. Create a script to build a Docker image that uses the host's port 8000 to accept trffic, and should not use any host storage (no volumns). When that's done, run the Docker image and test it using the curl scripts."

> "In the ballerina directory, create an API implementation using the Ballerina language that conforms to the API as described in joke.api. Make sure this project has unit tests to test the functionality at the domain and persistence layers. Make sure the unit tests pass, then make sure the scripts in the tests directory pass. Create a script to build a Docker image that uses the host's port 8000 to accept trffic, and should not use any host storage (no volumns). When that's done, run the Docker image and test it using the curl scripts."

