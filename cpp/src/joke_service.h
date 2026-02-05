#ifndef JOKE_SERVICE_H
#define JOKE_SERVICE_H

#include "joke.h"
#include "joke_repository.h"
#include <vector>
#include <string>

class JokeService {
public:
    JokeService(JokeRepository& repository);
    
    Joke createJoke(const Joke& joke);
    std::vector<Joke> getAllJokes(int limit = 100, int offset = 0);
    std::vector<Joke> getJokesBySource(const std::string& source);
    std::vector<Joke> getJokesByCategory(const std::string& category);
    Joke getJokeById(const std::string& id);
    Joke updateJoke(const std::string& id, const Joke& joke);
    bool deleteJoke(const std::string& id);
    Joke getRandomJoke(const std::string& category = "");
    bool bumpLolCount(const std::string& id);
    bool bumpGroanCount(const std::string& id);

private:
    JokeRepository& repository_;
};

#endif // JOKE_SERVICE_H