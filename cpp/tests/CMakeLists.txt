# Simple test CMakeLists.txt for C++ implementation
cmake_minimum_required(VERSION 3.10)
project(JokeAPITests)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(nlohmann_json URL https://github.com/nlohmann/json/releases/download/v3.12.0/json.tar.xz)
FetchContent_MakeAvailable(nlohmann_json)

# Find required packages
find_package(PkgConfig REQUIRED)
find_package(sqlite3 REQUIRED)
find_package(nlohmann_json REQUIRED)

# Add test executable
add_executable(test_joke tests/test_joke.cpp src/joke.cpp)

# Link libraries
target_link_libraries(test_joke 
    sqlite3
    nlohmann_json::nlohmann_json
)

# Include directories
target_include_directories(test_joke PRIVATE src)