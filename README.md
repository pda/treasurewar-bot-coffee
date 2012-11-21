Treasure Wars Bot: &lt;canvas&gt; + Socket.IO + CoffeeScript
============================================================

See: [https://github.com/mtcmorris/treasurewar](https://github.com/mtcmorris/treasurewar)

This bot was hacked together at [Rails Camp 12](http://railscamps.com/) in a
weekend, using some new code and some components recycled from my earlier
(totally unfinished) work on [bottom_up](http://github.com/pda/bottom_up).

Exploration and other pathfinding is done using a modified
[A\* search algorithm](http://en.wikipedia.org/wiki/A*_search_algorithm),
with the heuristic cost analysis zeroed out for exploration to unknown destinations.

The PointSet class had a last-minute optimisation using
[Uint8Array](https://developer.mozilla.org/en-US/docs/JavaScript_typed_arrays/Uint8Array)
and still contains a hard-coded size limit :(

None of this is likely to work in anything but Chrome.


Thanks
------

Thanks to [Michael Morris](https://github.com/mtcmorris) for creating the game
server, [Gabe Hollombe](http://avantbard.com/) for making the server do cool stuff
(with tests!), and [Dennis Hotson](https://github.com/dhotson) for assorted mad skills.


Instructions
------------

[CoffeeScript](http://coffeescript.org/) is required to build it into JavaScript.
You'll probably be wanting [Node.JS](http://nodejs.org/) and
[coffee-script via NPM](https://npmjs.org/package/coffee-script) for that.

Running `./watch.sh` should get things building.

Given a [Treasure War](https://github.com/mtcmorris/treasurewar) server running
on localhost:8000 and this bot being served as localhost:8001, run the bot in your
browser like this:

    http://localhost:8001/#treasure-war:8000

That is: `http://BOT_HOST/#GAME_SERVER_HOST`

Personally I use `www 8001` ala https://gist.github.com/3300372 to serve the bot code.
[SimpleHTTPServer](http://docs.python.org/2/library/simplehttpserver.html) is also
cool for that (but doesn't serve no-cache headers).


License
-------

[The MIT License](http://opensource.org/licenses/MIT)
