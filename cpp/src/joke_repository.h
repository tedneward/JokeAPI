#ifndef JOKE_REPOSITORY_H
#define JOKE_REPOSITORY_H

#include "joke.h"
#include <vector>
#include <string>

class JokeRepository {
public:
    JokeRepository(const std::string& db_path);
    ~JokeRepository();

    bool initialize();
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
    std::string db_path_;
    bool db_initialized_;
};

#endif // JOKE_REPOSITORY_H