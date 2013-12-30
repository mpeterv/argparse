largparse
=========

Feature-rich command line parser for Lua inspired by argparse for Python. 

WIP. 

Something already works:

```lua

local largparse = require "largparse"

local parser = largparse.parser()

parser:argument("input", {
   args = 2
})

parser:mutually_exclusive(
   parser:flag("-q", "--quiet"),
   parser:option("-s", "--server")
)

local run = parser:command "run"

run:flag("-f", "--fast")

local args = parser:parse()

```

TODO L1
=======

* Fix strange messages for not passed arguments
* Improve error messages: delegate them to parser, have separate methods for each error type
* Tests

TODO L2
=======

* More tests
* Add defaults
* Add converters
* Add choices
* Make interface decalrative
* Refactor Parser
* Write primitive ugly usage and help message generation

TODO L3
=======

* Tests with 100% coverage
* Document with LuaDoc/LDoc
* Add examples
* Add suggestions for command errors(e.g. `$ luarocks isntall` -> `Did you mean 'install'?`)
* Add pretty formatted usage and help messages
* Set up travis-ci testing

TODO L4
=======

* Release

