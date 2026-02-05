#include "http_server.h"
#include <iostream>
#include <sstream>
#include <regex>
#include <nlohmann/json.hpp>

// Simple HTTP server implementation using sockets
// Note: This is a minimal implementation for demonstration purposes
// In a production environment, you'd want to use a proper HTTP library

HttpServer::HttpServer(JokeService& service, int port) 
    : service_(service), port_(port), running_(false) {}

HttpServer::~HttpServer() {
    stop();
}

void HttpServer::start() {
    running_ = true;
    std::cout << "Starting HTTP server on port " << port_ << std::endl;
    // In a real implementation, this would start the actual HTTP server
    // For now, we'll just simulate the server running
    while (running_) {
        // Simulate server running
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

void HttpServer::stop() {
    running_ = false;
    std::cout << "HTTP server stopped" << std::endl;
}

void HttpServer::handleRequest(const std::string& method, const std::string& path, 
                               const std::string& body, std::string& response, int& status) {
    try {
        if (path == "/jokes" && method == "GET") {
            handleGetJokes(body, response, status);
        } else if (path == "/jokes" && method == "POST") {
            handlePostJokes(body, response, status);
        } else if (path.find("/jokes/") == 0 && method == "GET") {
            // Extract ID from path
            std::regex id_regex("/jokes/([^/]+)");
            std::smatch match;
            if (std::regex_search(path, match, id_regex)) {
                std::string id = match[1].str();
                handleGetJokeById(id, response, status);
            } else {
                status = 404;
                response = "{\"error\":\"Not found\"}";
            }
        } else if (path.find("/jokes/") == 0 && method == "PUT") {
            // Extract ID from path
            std::regex id_regex("/jokes/([^/]+)");
            std::smatch match;
            if (std::regex_search(path, match, id_regex)) {
                std::string id = match[1].str();
                handlePutJokeById(id, body, response, status);
            } else {
                status = 404;
                response = "{\"error\":\"Not found\"}";
            }
        } else if (path.find("/jokes/") == 0 && method == "DELETE") {
            // Extract ID from path
            std::regex id_regex("/jokes/([^/]+)");
            std::smatch match;
            if (std::regex_search(path, match, id_regex)) {
                std::string id = match[1].str();
                handleDeleteJokeById(id, response, status);
            } else {
                status = 404;
                response = "{\"error\":\"Not found\"}";
            }
        } else if (path == "/jokes/random" && method == "GET") {
            handleGetRandomJoke(body, response, status);
        } else if (path.find("/jokes/") == 0 && method == "POST") {
            // Check if it's a bump endpoint
            if (path.find("/bump-lol") != std::string::npos) {
                std::regex id_regex("/jokes/([^/]+)/bump-lol");
                std::smatch match;
                if (std::regex_search(path, match, id_regex)) {
                    std::string id = match[1].str();
                    handlePostBumpLol(id, response, status);
                } else {
                    status = 404;
                    response = "{\"error\":\"Not found\"}";
                }
            } else if (path.find("/bump-groan") != std::string::npos) {
                std::regex id_regex("/jokes/([^/]+)/bump-groan");
                std::smatch match;
                if (std::regex_search(path, match, id_regex)) {
                    std::string id = match[1].str();
                    handlePostBumpGroan(id, response, status);
                } else {
                    status = 404;
                    response = "{\"error\":\"Not found\"}";
                }
            } else {
                status = 404;
                response = "{\"error\":\"Not found\"}";
            }
        } else {
            status = 404;
            response = "{\"error\":\"Not found\"}";
        }
    } catch (const std::exception& e) {
        status = 500;
        response = "{\"error\":\"Internal server error\"}";
    }
}

void HttpServer::handleGetJokes(const std::string& query, std::string& response, int& status) {
    // Parse query parameters
    std::string source = "";
    std::string category = "";
    int limit = 100;
    int offset = 0;
    
    // Simple parsing of query parameters
    size_t source_pos = query.find("source=");
    if (source_pos != std::string::npos) {
        source = query.substr(source_pos + 7); // +7 to skip "source="
        size_t amp_pos = source.find("&");
        if (amp_pos != std::string::npos) {
            source = source.substr(0, amp_pos);
        }
    }
    
    size_t category_pos = query.find("category=");
    if (category_pos != std::string::npos) {
        category = query.substr(category_pos + 9); // +9 to skip "category="
        size_t amp_pos = category.find("&");
        if (amp_pos != std::string::npos) {
            category = category.substr(0, amp_pos);
        }
    }
    
    std::vector<Joke> jokes;
    if (!source.empty()) {
        jokes = service_.getJokesBySource(source);
    } else if (!category.empty()) {
        jokes = service_.getJokesByCategory(category);
    } else {
        jokes = service_.getAllJokes(limit, offset);
    }
    
    nlohmann::json json_response;
    json_response["jokes"] = jokes;
    response = json_response.dump();
    status = 200;
}

void HttpServer::handlePostJokes(const std::string& body, std::string& response, int& status) {
    try {
        nlohmann::json json_body = nlohmann::json::parse(body);
        Joke joke;
        joke.setup = json_body.value("setup", "");
        joke.punchline = json_body.value("punchline", "");
        joke.category = json_body.value("category", "");
        joke.source = json_body.value("source", "ted");
        joke.lolCount = json_body.value("lolCount", 0);
        joke.groanCount = json_body.value("groanCount", 0);
        
        Joke created_joke = service_.createJoke(joke);
        nlohmann::json json_response = created_joke;
        response = json_response.dump();
        status = 201;
    } catch (const std::exception& e) {
        status = 400;
        response = "{\"error\":\"Invalid JSON\"}";
    }
}

void HttpServer::handleGetJokeById(const std::string& id, std::string& response, int& status) {
    Joke joke = service_.getJokeById(id);
    if (joke.id.empty()) {
        status = 404;
        response = "{\"error\":\"Not found\"}";
    } else {
        nlohmann::json json_response = joke;
        response = json_response.dump();
        status = 200;
    }
}

void HttpServer::handlePutJokeById(const std::string& id, const std::string& body, std::string& response, int& status) {
    try {
        nlohmann::json json_body = nlohmann::json::parse(body);
        Joke joke;
        joke.setup = json_body.value("setup", "");
        joke.punchline = json_body.value("punchline", "");
        joke.category = json_body.value("category", "");
        joke.source = json_body.value("source", "ted");
        joke.lolCount = json_body.value("lolCount", 0);
        joke.groanCount = json_body.value("groanCount", 0);
        
        Joke updated_joke = service_.updateJoke(id, joke);
        if (updated_joke.id.empty()) {
            status = 404;
            response = "{\"error\":\"Not found\"}";
        } else {
            nlohmann::json json_response = updated_joke;
            response = json_response.dump();
            status = 200;
        }
    } catch (const std::exception& e) {
        status = 400;
        response = "{\"error\":\"Invalid JSON\"}";
    }
}

void HttpServer::handleDeleteJokeById(const std::string& id, std::string& response, int& status) {
    if (service_.deleteJoke(id)) {
        status = 204;
        response = "";
    } else {
        status = 404;
        response = "{\"error\":\"Not found\"}";
    }
}

void HttpServer::handleGetRandomJoke(const std::string& query, std::string& response, int& status) {
    std::string category = "";
    
    // Parse category from query
    size_t category_pos = query.find("category=");
    if (category_pos != std::string::npos) {
        category = query.substr(category_pos + 9); // +9 to skip "category="
        size_t amp_pos = category.find("&");
        if (amp_pos != std::string::npos) {
            category = category.substr(0, amp_pos);
        }
    }
    
    Joke joke = service_.getRandomJoke(category);
    if (joke.id.empty()) {
        status = 404;
        response = "{\"error\":\"No jokes found\"}";
    } else {
        nlohmann::json json_response = joke;
        response = json_response.dump();
        status = 200;
    }
}

void HttpServer::handlePostBumpLol(const std::string& id, std::string& response, int& status) {
    if (service_.bumpLolCount(id)) {
        Joke joke = service_.getJokeById(id);
        nlohmann::json json_response;
        json_response["id"] = joke.id;
        json_response["lolCount"] = joke.lolCount;
        json_response["groanCount"] = joke.groanCount;
        response = json_response.dump();
        status = 200;
    } else {
        status = 404;
        response = "{\"error\":\"Not found\"}";
    }
}

void HttpServer::handlePostBumpGroan(const std::string& id, std::string& response, int& status) {
    if (service_.bumpGroanCount(id)) {
        Joke joke = service_.getJokeById(id);
        nlohmann::json json_response;
        json_response["id"] = joke.id;
        json_response["lolCount"] = joke.lolCount;
        json_response["groanCount"] = joke.groanCount;
        response = json_response.dump();
        status = 200;
    } else {
        status = 404;
        response = "{\"error\":\"Not found\"}";
    }
}