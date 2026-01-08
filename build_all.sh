# Build csharp Docker image
cd csharp; ./build.sh; cd ..

# Build javalin Docker image
cd javalin; ./gradlew dockerBuild; cd ..

# Build kotlin Docker image
cd kotlin; ./gradlew dockerBuild; cd ..

# Build nestjs Docker image
cd nestjs; npm run docker-build; cd ..

# Build python Docker image
cd python; ./build_docker.sh; cd ..
