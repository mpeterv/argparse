# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)
[![Coverage Status](https://coveralls.io/repos/mpeterv/argparse/badge.svg?branch=master&service=github)](https://coveralls.io/github/mpeterv/argparse?branch=master)

Argparse is a feature-rich command line parser for Lua inspired by argparse for Python.

Argparse supports positional arguments, options, flags, optional arguments, subcommands and more. Argparse automatically generates usage, help and error messages.

Simple example: 

```lua
-- script.lua
local argparse = require "argparse"

local parser = argparse("script", "An example.")
parser:argument("input", "Input file.")
parser:option("-o --output", "Output file.", "a.out")
parser:option("-I --include", "Include locations."):count("*")

local args = parser:parse()
print(args)  -- Assuming print is patched to handle tables nicely.
```

```bash
$ lua script.lua foo
```

```lua
{
   input = "foo",
   output = "a.out",
   include = {}
}
```

```bash
$ lua script.lua foo -I/usr/local/include -Isrc -o bar
```

```lua
{
   input = "foo",
   output = "bar",
   include = {"/usr/local/include", "src"}
}
```

```bash
$ lua script.lua foo bar
```

```
Usage: script [-o <output>] [-I <include>] [-h] <input>

Error: too many arguments
```

```bash
$ lua script.lua --help
```

```
Usage: script [-o <output>] [-I <include>] [-h] <input>

An example. 

Arguments: 
   input                 Input file.

Options: 
   -o <output>, --output <output>
                         Output file. (default: a.out)
   -I <include>, --include <include>
                         Include locations.
   -h, --help            Show this help message and exit.
```

```bash
$ lua script.lua foo --outptu=bar
```

```
Usage: script [-o <output>] [-I <include>] [-h] <input>

Error: unknown option '--outptu'
Did you mean '--output'?
```

## Contents

* [Installation](#installation)
* [Tutorial](#tutorial)
* [Testing](#testing)
* [License](#license)

## Installation

### Using LuaRocks

Installing argparse using [LuaRocks](http://luarocks.org) is simple:

```bash
$ luarocks install argparse
```

### Without LuaRocks

Download `src/argparse.lua` file and put it into the directory for Lua libraries or your working directory.

## Tutorial

The tutorial is available [online](http://argparse.readthedocs.org). If argparse has been installed using LuaRocks 2.1.2 or later, it can be viewed using `luarocks doc argparse` command.

Tutorial HTML files can be built using [Sphinx](http://sphinx-doc.org/): `sphinx-build docsrc doc`, the files will be found inside `doc/`.

## Testing

argparse comes with a testing suite located in `spec` directory. [busted](http://olivinelabs.com/busted/) is required for testing, it can be installed using LuaRocks. Run the tests using `busted` command from the argparse folder.

## License

argparse is licensed under the same terms as Lua itself (MIT license).
