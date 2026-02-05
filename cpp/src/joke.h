#ifndef JOKE_H
#define JOKE_H

#include <string>
#include <nlohmann/json.hpp>

struct Joke {
public:
    std::string id;
    std::string setup;
    std::string punchline;
    std::string category;
    std::string source;
    int lolCount;
    int groanCount;

    Joke();
    Joke(const std::string& setup, const std::string& punchline);
    Joke(const std::string& id, const std::string& setup, const std::string& punchline, 
         const std::string& category, const std::string& source, int lolCount, int groanCount);

    // JSON serialization
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(Joke, id, setup, punchline, category, source, lolCount, groanCount)
};

#endif // JOKE_H