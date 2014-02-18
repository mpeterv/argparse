# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

argparse is a feature-rich command line parser for Lua inspired by argparse for Python. 

## Example

Let's create a command-line script which takes one positional argument and an option. 

```lua
-- script.lua
local argparse = require "argparse"

local parser = argparse:new()
parser:argument "input"
parser:option "-o" "--output"

local args = parser:parse()
for k, v in pairs(args) do
   print(k, v)
end
```

Does it work?

```bash
$ lua script.lua -o out.txt in.txt
```

```
input	in.txt
output	out.txt
```

There are several ways to pass options. 

```bash
$ lua script.lua --output out.txt in.txt
$ lua script.lua in.txt --output=out.txt
$ lua script.lua in.txt -oout.txt
```

Does it provide help?

```bash
$ lua script.lua --help
```

```
Usage: test.lua [-o <output>] [-h] <input>

Arguments: 
   input

Options: 
   -o <output>, --output <output>
   -h, --help            Show this help message and exit. 
```

What if we do something wrong?

```bash
$ lua script.lua foo bar
```

```
Usage: test.lua [-o <output>] [-h] <input>

Error: too many arguments
```

What if we make a typo?

```bash
$ lua script.lua in.txt --outptu out.txt
```

```
Usage: test.lua [-o <output>] [-h] <input>

Error: unknown option '--outptu'
Did you mean '--output'?
```

## Installation

### Using luarocks

Installing argparse using luarocks ~~is~~ will be easy. 

```bash
luarocks install argparse
```

#### Problems with old luarocks versions

You may get an error like `Parse error processing dependency '30log >= 0.8'` if you use luarocks 2.1 or older. In this case, either upgrade to at least luarocks 2.1.1 or install [30log](http://yonaba.github.io/30log/) manually, then download the rockspec for argparse, remove the line `"30log >= 0.8"` and run

```bash
luarocks install /path/to/argparse/rockspec
```

### Without luarocks

Download `/src/argparse.lua` file and put it into the directory for libraries or your working directory. Install 30log using luarocks or manually download `30log.lua` file from [30log repo](https://github.com/Yonaba/30log). 

## Documentation

Documentation is availible in the `doc` directory and [online](http://mpeterv.github.io/argparse). If argparse was installed using luarocks 2.1.2 or later, it can be viewed using `luarocks doc argparse` command. 

## Testing

argparse comes with a testing suite located in `spec` directory. [busted](http://olivinelabs.com/busted/) is required for testing, it can be installed using luarocks. Run the tests using `busted spec` command from the argparse folder. 

