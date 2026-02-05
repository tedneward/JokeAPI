#include "joke_repository.h"
#include <sqlite3.h>
#include <iostream>
#include <random>
#include <algorithm>
#include <sstream>

JokeRepository::JokeRepository(const std::string& db_path) : db_path_(db_path), db_initialized_(false) {}

JokeRepository::~JokeRepository() {}

bool JokeRepository::initialize() {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return false;
    }
    
    const char* sql = R"(
        CREATE TABLE IF NOT EXISTS jokes (
            id TEXT PRIMARY KEY,
            setup TEXT NOT NULL,
            punchline TEXT NOT NULL,
            category TEXT,
            source TEXT,
            lolCount INTEGER DEFAULT 0,
            groanCount INTEGER DEFAULT 0
        );
    )";
    
    char* errMsg = 0;
    rc = sqlite3_exec(db, sql, 0, 0, &errMsg);
    
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_close(db);
    db_initialized_ = true;
    return true;
}

Joke JokeRepository::createJoke(const Joke& joke) {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    // Generate a unique ID
    std::string id = "joke_" + std::to_string(std::random_device{}());
    
    std::string sql = R"(
        INSERT INTO jokes (id, setup, punchline, category, source, lolCount, groanCount)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    )";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 2, joke.setup.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 3, joke.punchline.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 4, joke.category.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 5, joke.source.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_int(stmt, 6, joke.lolCount);
    sqlite3_bind_int(stmt, 7, joke.groanCount);
    
    rc = sqlite3_step(stmt);
    
    if (rc != SQLITE_DONE) {
        std::cerr << "Failed to execute statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return Joke();
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
    return Joke(id, joke.setup, joke.punchline, joke.category, joke.source, joke.lolCount, joke.groanCount);
}

std::vector<Joke> JokeRepository::getAllJokes(int limit, int offset) {
    std::vector<Joke> jokes;
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return jokes;
    }
    
    std::string sql = "SELECT id, setup, punchline, category, source, lolCount, groanCount FROM jokes LIMIT ? OFFSET ?";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return jokes;
    }
    
    sqlite3_bind_int(stmt, 1, limit);
    sqlite3_bind_int(stmt, 2, offset);
    
    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        jokes.emplace_back(
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))),
            sqlite3_column_int(stmt, 5),
            sqlite3_column_int(stmt, 6)
        );
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return jokes;
}

std::vector<Joke> JokeRepository::getJokesBySource(const std::string& source) {
    std::vector<Joke> jokes;
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return jokes;
    }
    
    std::string sql = "SELECT id, setup, punchline, category, source, lolCount, groanCount FROM jokes WHERE source = ?";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return jokes;
    }
    
    sqlite3_bind_text(stmt, 1, source.c_str(), -1, SQLITE_STATIC);
    
    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        jokes.emplace_back(
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))),
            sqlite3_column_int(stmt, 5),
            sqlite3_column_int(stmt, 6)
        );
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return jokes;
}

std::vector<Joke> JokeRepository::getJokesByCategory(const std::string& category) {
    std::vector<Joke> jokes;
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return jokes;
    }
    
    std::string sql = "SELECT id, setup, punchline, category, source, lolCount, groanCount FROM jokes WHERE category = ?";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return jokes;
    }
    
    sqlite3_bind_text(stmt, 1, category.c_str(), -1, SQLITE_STATIC);
    
    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        jokes.emplace_back(
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))),
            sqlite3_column_int(stmt, 5),
            sqlite3_column_int(stmt, 6)
        );
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return jokes;
}

Joke JokeRepository::getJokeById(const std::string& id) {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    std::string sql = "SELECT id, setup, punchline, category, source, lolCount, groanCount FROM jokes WHERE id = ?";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_STATIC);
    
    if ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        Joke joke(
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))),
            sqlite3_column_int(stmt, 5),
            sqlite3_column_int(stmt, 6)
        );
        
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return joke;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return Joke();
}

Joke JokeRepository::updateJoke(const std::string& id, const Joke& joke) {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    std::string sql = R"(
        UPDATE jokes SET setup = ?, punchline = ?, category = ?, source = ?, lolCount = ?, groanCount = ?
        WHERE id = ?
    )";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    sqlite3_bind_text(stmt, 1, joke.setup.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 2, joke.punchline.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 3, joke.category.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 4, joke.source.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_int(stmt, 5, joke.lolCount);
    sqlite3_bind_int(stmt, 6, joke.groanCount);
    sqlite3_bind_text(stmt, 7, id.c_str(), -1, SQLITE_STATIC);
    
    rc = sqlite3_step(stmt);
    
    if (rc != SQLITE_DONE) {
        std::cerr << "Failed to execute statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return Joke();
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
    return getJokeById(id);
}

bool JokeRepository::deleteJoke(const std::string& id) {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return false;
    }
    
    std::string sql = "DELETE FROM jokes WHERE id = ?";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_STATIC);
    
    rc = sqlite3_step(stmt);
    
    if (rc != SQLITE_DONE) {
        std::cerr << "Failed to execute statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return true;
}

Joke JokeRepository::getRandomJoke(const std::string& category) {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    std::string sql;
    sqlite3_stmt* stmt;
    
    if (category.empty()) {
        sql = "SELECT id, setup, punchline, category, source, lolCount, groanCount FROM jokes ORDER BY RANDOM() LIMIT 1";
    } else {
        sql = "SELECT id, setup, punchline, category, source, lolCount, groanCount FROM jokes WHERE category = ? ORDER BY RANDOM() LIMIT 1";
    }
    
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return Joke();
    }
    
    if (!category.empty()) {
        sqlite3_bind_text(stmt, 1, category.c_str(), -1, SQLITE_STATIC);
    }
    
    if ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        Joke joke(
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))),
            std::string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))),
            sqlite3_column_int(stmt, 5),
            sqlite3_column_int(stmt, 6)
        );
        
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return joke;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return Joke();
}

bool JokeRepository::bumpLolCount(const std::string& id) {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return false;
    }
    
    std::string sql = "UPDATE jokes SET lolCount = lolCount + 1 WHERE id = ?";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_STATIC);
    
    rc = sqlite3_step(stmt);
    
    if (rc != SQLITE_DONE) {
        std::cerr << "Failed to execute statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return true;
}

bool JokeRepository::bumpGroanCount(const std::string& id) {
    sqlite3* db;
    int rc = sqlite3_open(db_path_.c_str(), &db);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return false;
    }
    
    std::string sql = "UPDATE jokes SET groanCount = groanCount + 1 WHERE id = ?";
    
    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, NULL);
    
    if (rc != SQLITE_OK) {
        std::cerr << "Failed to prepare statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_STATIC);
    
    rc = sqlite3_step(stmt);
    
    if (rc != SQLITE_DONE) {
        std::cerr << "Failed to execute statement: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return false;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return true;
}