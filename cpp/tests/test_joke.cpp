#include "joke.h"
#include <cassert>
#include <iostream>

void test_joke_creation() {
    std::cout << "Testing Joke creation..." << std::endl;
    
    // Test default constructor
    Joke joke1;
    assert(joke1.id.empty());
    assert(joke1.lolCount == 0);
    assert(joke1.groanCount == 0);
    
    // Test constructor with setup and punchline
    Joke joke2("Why did the chicken cross the road?", "To get to the other side!");
    assert(joke2.setup == "Why did the chicken cross the road?");
    assert(joke2.punchline == "To get to the other side!");
    assert(joke2.lolCount == 0);
    assert(joke2.groanCount == 0);
    
    // Test full constructor
    Joke joke3("id123", "Why did the chicken cross the road?", "To get to the other side!", 
               "Chicken", "ted", 5, 3);
    assert(joke3.id == "id123");
    assert(joke3.setup == "Why did the chicken cross the road?");
    assert(joke3.punchline == "To get to the other side!");
    assert(joke3.category == "Chicken");
    assert(joke3.source == "ted");
    assert(joke3.lolCount == 5);
    assert(joke3.groanCount == 3);
    
    std::cout << "All Joke creation tests passed!" << std::endl;
}

int main() {
    test_joke_creation();
    return 0;
}