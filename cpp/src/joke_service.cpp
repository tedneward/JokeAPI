#include "joke_service.h"

JokeService::JokeService(JokeRepository& repository) : repository_(repository) {}

Joke JokeService::createJoke(const Joke& joke) {
    return repository_.createJoke(joke);
}

std::vector<Joke> JokeService::getAllJokes(int limit, int offset) {
    return repository_.getAllJokes(limit, offset);
}

std::vector<Joke> JokeService::getJokesBySource(const std::string& source) {
    return repository_.getJokesBySource(source);
}

std::vector<Joke> JokeService::getJokesByCategory(const std::string& category) {
    return repository_.getJokesByCategory(category);
}

Joke JokeService::getJokeById(const std::string& id) {
    return repository_.getJokeById(id);
}

Joke JokeService::updateJoke(const std::string& id, const Joke& joke) {
    return repository_.updateJoke(id, joke);
}

bool JokeService::deleteJoke(const std::string& id) {
    return repository_.deleteJoke(id);
}

Joke JokeService::getRandomJoke(const std::string& category) {
    return repository_.getRandomJoke(category);
}

bool JokeService::bumpLolCount(const std::string& id) {
    return repository_.bumpLolCount(id);
}

bool JokeService::bumpGroanCount(const std::string& id) {
    return repository_.bumpGroanCount(id);
}