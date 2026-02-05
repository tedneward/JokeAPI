#ifndef HTTP_SERVER_H
#define HTTP_SERVER_H

#include "joke_service.h"
#include <string>
#include <functional>

class HttpServer {
public:
    HttpServer(JokeService& service, int port = 8000);
    ~HttpServer();
    
    void start();
    void stop();
    
private:
    JokeService& service_;
    int port_;
    bool running_;
    
    void handleRequest(const std::string& method, const std::string& path, 
                       const std::string& body, std::string& response, int& status);
    
    // HTTP handlers
    void handleGetJokes(const std::string& query, std::string& response, int& status);
    void handlePostJokes(const std::string& body, std::string& response, int& status);
    void handleGetJokeById(const std::string& id, std::string& response, int& status);
    void handlePutJokeById(const std::string& id, const std::string& body, std::string& response, int& status);
    void handleDeleteJokeById(const std::string& id, std::string& response, int& status);
    void handleGetRandomJoke(const std::string& query, std::string& response, int& status);
    void handlePostBumpLol(const std::string& id, std::string& response, int& status);
    void handlePostBumpGroan(const std::string& id, std::string& response, int& status);
};

#endif // HTTP_SERVER_H