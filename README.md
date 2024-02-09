# JokeAPI
An API (implemented in different languages and platforms) for a simple CRUD joke database

## Goals
Each Joke should consist of:

* setup text. ("Why did the chicken cross the road?")
* punchline text. ("To get to the other side!")
* a category (text). ("Chicken" or maybe "Cross the road") For simplicity, assume each joke can only be in one category. Defaults to "" for a new joke.
* the source (text): Who wrote this? If no source is cited for a new joke, we'll assume I wrote it.
* LOL count (integer): defaults to 0 for a new joke
* Groan count (integer): defaults to 0 for a new joke

We want the core CRUD functionality, but maybe do we want more granular (bump LOLs, bump groans, etc) as well?



## Implementations
Each directory holds its own implementation.

### `loopback`: LoopbackJS
Built this back in 2017 as part of either the MSDN column or the developerWorks column, I can't remember which. Used it briefly as part of the Angular workshop. Feels like we got the very basic CRUD functionality that's built-in to Loopback and never took it further. :-/

### `ballerina`: Ballerina
Idle fiddling with Ballerina to build the same thing. Ballerina's `isolated` is definitely just as cranky as C++'s `const` was/is.

### `jolie`: Jolie
Let's build one using Jolie and see how well that holds up.
