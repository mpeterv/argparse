# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

argparse is a feature-rich command line parser for Lua inspired by argparse for Python. 

argparse supports positional arguments, options, flags, optional arguments, subcommands and more. argparse automatically generates usage, help and error messages. 

Quick glance: 

```lua
-- script.lua
local argparse = require "argparse"
local parser = argparse()
   :description "An example."
parser:argument "input"
   :description "Input file."
parser:option "-o" "--output"
   :default "a.out"
   :description "Output file."
parser:option "-I" "--include"
   :count "*"
   :description "Include locations."
local args = parser:parse()
prettyprint(args)
```

```bash
$ lua script.lua foo
```

```
input: foo
output: a.out
include: {}
```

```bash
$ lua script.lua foo -I/usr/local/include -I/src -o bar
```

```
input: foo
output: bar
include: {/usr/local/include, /src}
```

```bash
$ lua script.lua foo bar
```

```
Usage: script.lua [-o <output>] [-I <include>] [-h] <input>

Error: too many arguments
```

```bash
$ lua script.lua --help
```

```
Usage: script.lua [-o <output>] [-I <include>] [-h] <input>

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
Usage: script.lua [-o <output>] [-I <include>] [-h] <input>

Error: unknown option '--outptu'
Did you mean '--output'?
```

## Contents

* [Installation](#installation)
* [Tutorial](#tutorial)
* [Testing](#testing)
* [License](#license)

## Installation

### Using luarocks

Installing argparse using luarocks ~~is~~ will be easy. 

```bash
$ luarocks install argparse
```

#### Problems with old luarocks versions

You may get an error like `Parse error processing dependency '30log >= 0.8'` if you use luarocks 2.1 or older. In this case, either upgrade to at least luarocks 2.1.1 or install [30log](http://yonaba.github.io/30log/) manually, then download the rockspec for argparse, remove the line `"30log >= 0.8"` and run

```bash
$ luarocks install /path/to/argparse/rockspec
```

### Without luarocks

Download `/src/argparse.lua` file and put it into the directory for libraries or your working directory. Install 30log using luarocks or manually download `30log.lua` file from [30log repo](https://github.com/Yonaba/30log). 


## Tutorial

The tutorial is available [online](http://mpeterv.github.io/argparse/) and in the `doc` directory. If argparse was installed using luarocks 2.1.2 or later, it can be viewed using `luarocks doc argparse` command. 

## Testing

argparse comes with a testing suite located in `spec` directory. [busted](http://olivinelabs.com/busted/) is required for testing, it can be installed using luarocks. Run the tests using `busted spec` command from the argparse folder. 

## License

argparse is licensed under the same terms as Lua itself(MIT license). 
