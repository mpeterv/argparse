# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

argparse is a feature-rich command line parser for Lua inspired by argparse for Python. 

TODO: 

* Finish tutorial
* Check grammar
* Write some documentation
* If an option has a default value and is under-used, invoke it with default value
* Don't invoke arguments if they are not used
* Make cli test windows friendly

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

### Creating a parser

The module contains the Parser class. To create an instance, call it or its `:new()` method. 

```lua
-- script.lua
local argparse = require "argparse"
local parser = argparse()
```

`parser` is now an empty parser which does not recognize any command line arguments or options. 

### Parsing command line arguments

`:parse([cmdline])` method of the Parser class returns a table with processed data from the command line or `cmdline` array. 

```lua
local args = parser:parse()
for k, v in pairs(args) do print(k, v) end
```

When executed, this script prints nothing because the parser is empty and no command line arguments were supplied. 

```bash
$ lua script.lua
```

#### Error handling

If the provided command line arguments are not recognized by the parser, it will print an error message and calls `os.exit(1)`. 

```bash
$ lua script.lua foo
```

```
Usage: script.lua [-h]

Error: too many arguments
```

If halting the program is undesirable, `:pparse([cmdline])` method should be used. It returns boolean flag indicating success of parsing and result or error message. 

#### Help option

As the automatically generated usage message states, there is a help option `-h` added to any parser by default. 

When a help option is used, parser will print a help message and call `os.exit(0)`. 

```bash
$ lua script.lua -h
```

```
Usage: script.lua [-h]

Options: 
   -h, --help            Show this help message and exit. 
```

#### Typo autocorrection

When an option is not recognized by the parser, but there is an option with a similar name, a suggestion is automatically added to the error message. 

```bash
$ lua script.lua --hepl
```

```
Usage: script.lua [-h]

Error: unknown option '--hepl'
Did you mean '--help'?
```

### Configuring parser

Parsers have several fields affecting their behaviour. For example, `description` field sets the text to be displayed in the help message between the usage message and the listings of options and arguments. Another is `name`, which overwrites the name of the program which is used in the usage message(default value is inferred from command line arguments). 

There are several ways to set fields. The first is to call a parser with a table containing some fields. 

```lua
local parser = argparse() {
   name = "script",
   description = "A testing script. "
}
```

The second is to chain setter methods of Parser object. 

```lua
local parser = argparse()
   :name "script"
   :description "A testing script. "
```

As a special case, `name` field can be set by calling a parser with a string. 

```lua
local parser = argparse "script"
   :description "A testing script. "
```

### Adding arguments

Positional arguments can be added using `:argument()` method. It returns an Argument instance, which can be configured in the same way as Parsers. The `name` field is required. 

```lua
parser:argument "input" -- sugar for :argument():name "input"
```

```bash
$ lua script.lua foo
```

```
input	foo
```

The data passed to the argument is stored in the result table at index `input` because it is the argument's name. The index can be changed using `target` field. 

#### Setting number of arguments

`args` field sets how many command line arguments the argument consumes. Its value is interpreted as follows: 

Value | Interpretation
--- | ---
Number `N` | Exactly `N` arguments
String `"A-B"`, where `A` and `B` are numbers | From `A` to `B` arguments
String `"N+"`, where `N` is a number | `N` or more arguments
String `"?"` | An optional argument
String `"*"` | Any number of arguments
Srting `"+"` | At least one argument

If more than one argument can be passed, a table is used to store the data. 

```lua
parser:argument "pair"
   :args(2)
   :description "A pair of arguments. "
parser:argument "optional"
   :args "?"
   :description "An optional argument. "
```

```bash
$ lua script.lua foo bar
```

```
pair	{foo, bar}
```

```bash
$ lua script2.lua foo bar baz
```

```
pair	{foo, bar}
optional	baz
```

### Adding options

Options can be added using `:option()` method. It returns an Option instance, which can be configured in the same way as Parsers. The `name` field is required. An option can have several aliases, which can be set using `aliases` field or by continuesly calling the Option instance. 

```lua
parser:option "-f" "--from"
```

```bash
$ lua script.lua --from there
$ lua script.lua --from=there
$ lua script.lua -f there
$ lua script.lua -fthere
```

```
from	there
```

For an option, default index used to store data is the first 'long' alias (an alias starting with two control characters) or just the first alias, without control characters. 

#### Flags

Flags are almost indentical to options, except that they don't take an argument by default. 

```lua
parser:flag "-q" "--quiet"
```

```bash
$ lua script.lua -q
```

```
quiet	true
```

#### Control characters

The first characters of all aliases of all options of a parser form the set of control characters, used to distinguish options from arguments. Typically the set only consists of a nyphen. 

#### Setting number of arguments

Just as arguments, options can be configured to take several command line arguments. 

```lua
parser:option "--pair"
   :args(2)
parser:option "--optional"
   :args "?"
```

```bash
$ lua script3.lua --pair foo bar
```

```
pair	{foo, bar}
```

```bash
$ lua script3.lua --pair foo bar --optional
```

```
pair	{foo, bar}
optional	{}
```

```bash
$ lua script3.lua --optional=baz
```

```
optional	{baz}
```

Note that the data passed to `optional` option is stored in an array. That is necessary to distiguish whether the option was invoked without an argument or it was not invoked at all. 

#### Setting number of invocations

For options, it is possible to control how many times they can be used. argparse uses `count` field to set how many times an option can be invoced. The value of the field is interpreted in the same way `args` is. 

```lua
parser:option "-e" "--exclude"
   :count "*"
```

```bash
$ lua script.lua -eFOO -eBAR
```

```
exclude	{FOO, BAR}
```

If an option can be used more than once and it can consume more than one argument, the data is stored as an array of invocations, each being an array of arguments. 

As a special case, if an option can be used more than once and it consumes no arguments(e.g. it's a flag), than the number of invocations is stored in associated field of the result table. 

```lua
parser:flag "-v" "--verbose"
   :count "0-2"
   :target "verbosity"
   :description [[Sets verbosity level. 
-v: Report all warning. 
-vv: Report all debugging information. ]]
```

```bash
$ lua script.lua -vv
```

```
verbosity	2
```

### Commands

### Default values

### Converters

### Actions

## Documentation

Documentation is not available in the `doc` directory and [online](http://mpeterv.github.io/argparse). If argparse was installed using luarocks 2.1.2 or later, it can not be viewed using `luarocks doc argparse` command. 

## Testing

argparse comes with a testing suite located in `spec` directory. [busted](http://olivinelabs.com/busted/) is required for testing, it can be installed using luarocks. Run the tests using `busted spec` command from the argparse folder. 

