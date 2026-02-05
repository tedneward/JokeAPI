cmake_minimum_required(VERSION 3.10)
project(JokeAPI)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

FetchContent_Declare(nlohmann_json URL https://github.com/nlohmann/json/releases/download/v3.12.0/json.tar.xz)
FetchContent_MakeAvailable(nlohmann_json)

# Find required packages
find_package(PkgConfig REQUIRED)
find_package(SQLite3 REQUIRED)
find_package(nlohmann_json REQUIRED)


# Add executable
add_executable(jokeapi
    src/main.cpp
    src/joke.cpp
    src/joke_repository.cpp
    src/joke_service.cpp
    src/http_server.cpp
)

# Link libraries
target_link_libraries(jokeapi 
    sqlite3
    nlohmann_json::nlohmann_json
)

# Include directories
target_include_directories(jokeapi PRIVATE src)
