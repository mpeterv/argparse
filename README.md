# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

argparse is a feature-rich command line parser for Lua inspired by argparse for Python. 

TODO: 

* Finish tutorial
* Check grammar
* Write some documentation
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

If the provided command line arguments are not recognized by the parser, it will print an error message and call `os.exit(1)`. 

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

Parsers have several fields affecting their behavior. For example, `description` field sets the text to be displayed in the help message between the usage message and the listings of options and arguments. Another is `name`, which overwrites the name of the program which is used in the usage message(default value is inferred from command line arguments). 

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
String `"+"` | At least one argument

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

Options can be added using `:option()` method. It returns an Option instance, which can be configured in the same way as Parsers. The `name` field is required. An option can have several aliases, which can be set using `aliases` field or by continuously calling the Option instance. 

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

Sometimes it is useful to explicitly set the index using `target` field to improve readability of help messages. 

```lua
parser:option "-f" "--from"
   :target "server"
```

```bash
$ lua script.lua --help
```

```
Usage: script.lua [-f <server>] [-h]

Options: 
   -f <server>, --from <server>
   -h, --help            Show this help message and exit. 
```

```bash
$ lua script.lua --from there
```

```
server	there
```

#### Flags

Flags are almost identical to options, except that they don't take an argument by default. 

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

The first characters of all aliases of all options of a parser form the set of control characters, used to distinguish options from arguments. Typically the set only consists of a hyphen. 

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

Note that the data passed to `optional` option is stored in an array. That is necessary to distinguish whether the option was invoked without an argument or it was not invoked at all. 

#### Setting number of invocations

For options, it is possible to control how many times they can be used. argparse uses `count` field to set how many times an option can be invoked. The value of the field is interpreted in the same way `args` is. 

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

A command is a subparser invoked when its name is passed as an argument. For example, in luarocks CLI `install`, `make`, `build`, etc. are commands. Each command has its own set of arguments and options. 

Commands can be added using `:command()` method. Just as options, commands can have several aliases. 

```lua
parser:command "install" "i"
```

If a command it used, `true` is stored in the corresponding field of the result table. 

```bash
$ lua script.lua install
```

```
install	true
```

A typo will result in an appropriate error message: 

```bash
$ lua script.lua instal
```

```
Usage: script.lua [-h] [<command>] ...

Error: unknown command 'instal'
Did you mean 'install'?
```

#### Adding elements to commands

The Command class is a subclass of the Parser class, so all the Parser's methods for adding elements work on commands, too. 

```lua
local install = parser:command "install"
install:argument "rock"
install:option "-f" "--from"
```

```bash
$ lua script.lua install foo --from=bar
```

```
install	true
rock	foo
from	bar
```

Commands have their own usage and help messages. 

```bash
$ lua script.lua install
```

```
Usage: script.lua install [-f <from>] [-h] <rock>

Error: too few arguments
```

```bash
$ lua script.lua install --help
```

```
Usage: script.lua install [-f <from>] [-h] <rock>

Arguments: 
   rock

Options: 
   -f <from>, --from <from>
   -h, --help            Show this help message and exit. 
```

### Default values

For arguments and options, if `default` field is set, its value is used as default argument. 

```lua
parser:argument "input"
   :default "input.txt"
```

```bash
$ lua script.lua
```

```
input	input.txt
```

The existence of a default value is reflected in help message. 

```bash
$ lua script.lua --help
```

```
Usage: script.lua [-h] [<input>]

Arguments: 
   input                 default: input.txt

Options: 
   -h, --help            Show this help message and exit. 
```

#### Default values and options

Note that if an option is not invoked, its default value will not be stored. 

```lua
parser:option "-o" "--output"
   :default "a.out"
```

```bash
$ lua script.lua -o
```

```
output	a.out
```

But

```bash
$ lua script.lua
```

produces nothing. 

That is because by default options can be not used at all. If default value must be used even when the option is not invoked, make the invocation obligatory. 

```lua
parser:option "-o" "--output"
   :default "a.out"
   :count(1)
```

```bash
$ lua script.lua
```

```
output	a.out
```

### Converters

argparse can perform automatic validation and conversion on arguments. If `convert` field of an element is a function, it will be applied to all the arguments passed to it. The function should return `nil` and, optionally, an error message if conversion failed. Standard `tonumber` and `io.open` functions work exactly like that. 

```lua
parser:argument "input"
   :convert(io.open)
parser:option "-t" "--times"
   :convert(tonumber)
```

```bash
$ lua script.lua foo.txt -t5
```

```
input	file (0xadress)
times	5 (number)
```

```bash
$ lua script.lua nonexistent.txt
```

```
Usage: script.lua [-t <times>] [-h] <input>

Error: nonexistent.txt: No such file or directory
```

```bash
$ lua script.lua foo.txt --times=many
```

```
Usage: script.lua [-t <times>] [-h] <input>

Error: malformed argument 'many'
```

#### Table converters

If `convert` field of an element contains a table, arguments passed to it will be used as keys. If a key is missing, an error is raised. 

```lua
parser:argument "choice"
   :convert {
      foo = "Something foo-related",
      bar = "Something bar-related"
   }
```

```bash
$ lua script.lua bar
```

```
choice	Something bar-related
```

```bash
$ lua script.lua baz
```

```
Usage: script.lua [-h] <choice>

Error: malformed argument 'baz'
```

### Actions

(Not yet written)

## Documentation

Documentation is not available in the `doc` directory and [online](http://mpeterv.github.io/argparse). If argparse was installed using luarocks 2.1.2 or later, it can not be viewed using `luarocks doc argparse` command. 

## Testing

argparse comes with a testing suite located in `spec` directory. [busted](http://olivinelabs.com/busted/) is required for testing, it can be installed using luarocks. Run the tests using `busted spec` command from the argparse folder. 

