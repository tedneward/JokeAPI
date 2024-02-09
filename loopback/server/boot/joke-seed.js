var async = require('async');

module.exports = function(app) {
    var Joke = app.models.Joke;

    async.parallel({
        jokes: async.apply(createJokeSeed)
    }, function(err, results) {
        if (err) throw err;
        console.log('joke seed created successfully');
    });

    function createJokeSeed(cb) {
        Joke.create([{
            Setup: "When Chuck Norris was denied a Bacon McMuffin at McDonalds because it was 10:35...",
            Punchline: "... he roundhouse kicked the store so hard it became a KFC.",
            Categories: ["Chuck Norris"],
            LOLCount: 0,
            GroanCount: 0
        }, {
            Setup: "Chuck Norris once roundhouse kicked someone so hard that his foot broke the speed of light, went back in time...",
            Punchline: "... and killed Amelia Earhart while she was flying over the Pacific Ocean.",
            Categories: ["Chuck Norris"],
            LOLCount: 0,
            GroanCount: 0
        }, {
            Setup: "Every night at 8:00, a truck pulls up to Chuck Norris’ house. In the truck are a bunch of orphans. For the next half-hour, Chuck Norris practices roundhouse kicks on the orphans while \“It’s a Hard Knock Life\” plays in the background.",
            Punchline: " At the end of the session, the orphans say \“Thank you, Mr. Norris.\” in perfect unison, then march into the truck in silence.",
            Categories: ["Chuck Norris"],
            LOLCount: 0,
            GroanCount: 0
        }, {
            Setup: "What time did the man go to the dentist?",
            Punchline: "Tooth hurt-y.",
            Categories: ["Dad"],
            LOLCount: 0,
            GroanCount: 0
        }, {
            Setup: "Did you hear about the guy who invented Mentos?",
            Punchline: "They say he made a mint.",
            Categories: ["Dad"],
            LOLCount: 0,
            GroanCount: 0
        }, {
            Setup: "A ham sandwich walks into a bar and orders a beer.",
            Punchline: "Bartender says, ‘Sorry we don’t serve food here.’",
            Categories: ["Dad"],
            LOLCount: 0,
            GroanCount: 0
        }, {
            Setup: "A woman is on trial for beating her husband to death with his guitar collection. Judge says, ‘First offender?’",
            Punchline: "She says, ‘No, first a Gibson! Then a Fender!’",
            Categories: ["Dad"],
            LOLCount: 0,
            GroanCount: 0
        }, {
            Setup: "What’s Forrest Gump’s password?",
            Punchline: "1forrest1",
            Categories: ["Dad"],
            LOLCount: 0,
            GroanCount: 0,
            Source: "http://www.short-funny.com/best-puns.php"
        }, {
            Setup: "I ate 4 bowls of delicious alphabet soup.",
            Punchline: "After that I had a massive vowel movement.",
            Categories: ["Dad"],
            LOLCount: 0,
            GroanCount: 0,
            Source: "http://www.short-funny.com/best-puns.php"
        }, {
            Setup: "Scientists used to believe that diamond was the world's hardest substance.",
            Punchline: "But then they met Chuck Norris, who gave them a roundhouse kick to the face so hard, and with so much heat and pressure, that the scientists turned into artificial Chuck Norris.",
            Categories: ["Chuck Norris"],
            LOLCount: 0,
            GroanCount: 0
        }], cb);
    };
};

/*
        {
            Setup: "",
            Punchline: "",
            Categories: ["Chuck Norris"],
            LOLCount: 0,
            GroanCount: 0
        }, 
 */