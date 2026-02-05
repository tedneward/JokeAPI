#include "joke.h"
#include "joke_repository.h"
#include "joke_service.h"
#include "http_server.h"
#include <iostream>
#include <thread>
#include <chrono>

int main() {
    std::cout << "Starting JokeAPI C++ Implementation" << std::endl;
    
    // Initialize database
    JokeRepository repository("jokes.db");
    if (!repository.initialize()) {
        std::cerr << "Failed to initialize database" << std::endl;
        return 1;
    }
    
    // Create service and server
    JokeService service(repository);
    HttpServer server(service, 8000);
    
    std::cout << "JokeAPI server starting on port 8000..." << std::endl;
    
    // Start server in a separate thread
    std::thread server_thread([&server]() {
        server.start();
    });
    
    // Keep main thread alive
    try {
        while (true) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
    } catch (...) {
        server.stop();
        if (server_thread.joinable()) {
            server_thread.join();
        }
    }
    
    return 0;
}