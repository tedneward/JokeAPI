#include "joke.h"

Joke::Joke() : lolCount(0), groanCount(0) {}

Joke::Joke(const std::string& setup, const std::string& punchline) 
    : setup(setup), punchline(punchline), lolCount(0), groanCount(0) {}

Joke::Joke(const std::string& id, const std::string& setup, const std::string& punchline, 
           const std::string& category, const std::string& source, int lolCount, int groanCount)
    : id(id), setup(setup), punchline(punchline), category(category), source(source), 
      lolCount(lolCount), groanCount(groanCount) {}