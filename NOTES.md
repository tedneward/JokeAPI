# Notes

*This file is for humans only; AI agents should not read or ingest any information in here.*

One thought: When creating a new project, put all the build environment setup into a Dockerfile and then build entirely within that Docker image; it'll help with configuration of build environments immensely, I think. (Should've thought of that before starting this project, but maybe I'll refactor that into the project later sometime.)

Most of this was generated using the Claude Haiku model, I think. I'm still getting used to understanding how to work with the different models from within VS Code.

With the exception of Ballerina, I didn't touch any of the code, though the Kotlin project had some problems getting Gradle configured correctly (I eventually had to bootstrap a Gradle file into existence). I also ended up having to `gradle wrapper` in the javalin directory to get the Gradle wrapper in place. (Not necessary, per se, but I'm used to having the wrapper available in Gradle projects.)

I'm going to try the Continue extension against Ollama models to do some additional implementations, I think.

At some point I should try to normalize the SQLite storage and refactor all the implementations to use that instead of making up their own.

