# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

argparse is a feature-rich command line parser for Lua inspired by argparse for Python. 

## Status

Almost everything is implemented, and a WIP version will be available soon. 

TODO till first release: 

* Add `Content` section to this README. 
* Add a small example to the beginning of this README. 
* Check the grammar in this README. 
* Generate .html file from the tutorial part of this README and put it into `doc` directory. 
* Write a rockspec for `v0.1` and push it to moonrocks. 

TODO till first 'stable' release: 

* Write a formal reference. 
* Write more tests. Some cases are still poorly covered. 
* Add mutually exclusive groups(`:mutex{option1, option2, ...}`). 
* Optionally(?): Add comments to the source. 
* Optionally: get rid of `30log` dependency. It's great but can cause problems with old luarocks versions. 

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

The module is a function which, when called, creates an instance of the Parser class. 

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

An error can raised manually using `:error()` method. 

```lua
parser:error("manual argument validation failed")
```

```
Usage: script.lua [-h]

Error: manual argument validation failed
```

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
Usage: script.lua [-h] <command> ...

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

#### Making a command optional

By default, if a parser has commands, using one of them is obligatory. 

```lua
local parser = argparse()
parser:command "install"
```

```bash
$ lua script.lua
```

```
Usage: script.lua [-h] <command> ...

Error: a command is required
```

This can be changed using the `require_command` field. 

```lua
local parser = argparse()
   :require_command(false)
parser:command "install"
```

Now not using a command is not an error:

```bash
$ lua script.lua
```

produces nothing. 

### Default values

For elements such as arguments and options, if `default` field is set, its value is stored in case the element was not used. 

```lua
parser:option "-o" "--output"
   :default "a.out"
```

```bash
$ lua script.lua
```

```
output	a.out
```

The existence of a default value is reflected in help message. 

```bash
$ lua script.lua --help
```

```
Usage: script [-o <output>] [-h]

Options: 
   -o <output>, --output <output>
                         default: a.out
   -h, --help            Show this help message and exit. 
```

Note that invocation without required arguments is still an error. 

```bash
$ lua script.lua -o
```

```
Usage: script [-o <output>] [-h]

Error: too few arguments
```

#### Default mode

The `defmode` field regulates how argparse should use the default value of an element. 

If `defmode` contains `"u"`(for `unused`), the default value will be automatically passed to the element if it was not invoked at all. This is the default behavior. 

If `defmode` contains `"a"`(for `argument`), the default value will be automatically passed to the element if not enough arguments were passed, or not enough invocations were made. 

Consider the difference: 

```
parser:option "-o"
   :default "a.out"
parser:option "-p"
   :default "password"
   :defmode "arg"
```

```bash
$ lua script.lua -h
```

```
Usage: script [-o <o>] [-p [<p>]] [-h]

Options: 
   -o <o>                default: a.out
   -p [<p>]              default: password
   -h, --help            Show this help message and exit. 
```

```bash
$ lua script.lua
```

```
o	a.out
```

```bash
$ lua script.lua -p
```

```
o	a.out
p	password
```

```bash
$ lua script.lua -o
```

```
Usage: script [-o <o>] [-p [<p>]] [-h]

Error: too few arguments
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
input	file (0xaddress)
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

argparse can trigger a callback when an option or a command is encountered. The callback can be set using `action` field. Actions are called regardless of whether the rest of command line arguments are correct. 

```lua
parser:flag "-v" "--version"
   :description "Show version info and exit. "
   :action(function()
      print("script.lua v1.0.0")
      os.exit(0)
   end)
```

```bash
$ lua script.lua -v
```

```
script.lua v1.0.0
```

This example would work even if the script had mandatory arguments. 

### Miscellaneous

#### Overwriting default help option

If the field `add_help` of a parser is set to false, no help option will be added to it. Otherwise, the value of the field will be used to configure it. 

```lua
local parser = argparse()
   :add_help {name = "/?"}
```

```bash
$ lua script.lua /?
```

```
Usage: script.lua [/?]

Options: 
   /?                    Show this help message and exit.
```

#### Configuring usage and help messages

##### Description and epilog

The value of `description` field of a parser is placed between the usage message and the argument list in the help message. 

The value of `epilog` field is appended to the help message. 

```lua
local parser = argparse "script"
   :description "A description. "
   :epilog "An epilog. "
```

```bash
$ lua script.lua --help
```

```
Usage: script [-h]

A description. 

Options: 
   -h, --help            Show this help message and exit. 

An epilog. 
```

##### Argument placeholder

For options and arguments, `argname` field controls the placeholder for the argument in the usage message. 

```lua
parser:option "-f" "--from"
   :argname "<server>"
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

#### Prohibiting overuse of options

By default, if an option is invoked too many times, latest invocations overwrite the data passed earlier. 

```lua
parser:option "-o" "--output"
```

```bash
$ lua script.lua -oFOO -oBAR
```

```
output   BAR
```

Set the `overwrite` field to false to prohibit this behavior. 

```lua
parser:option "-o" "--output"
   :overwrite(false)
```

```bash
$ lua script.lua -oFOO -oBAR
```

```
Usage: script.lua [-o <output>] [-h]

Error: option '-o' must be used at most 1 time
```

#### Generating usage and help messages

`:get_help()` and `get_usage:()` methods of Parser and Command classes can be used to generate their help and usage messages. 

#### Parsing algorithm

argparse interprets command-line arguments in the following way: 

Argument | Interpretation
--- | ---
`foo` | An argument of an option or a positional argument. 
`--foo` | An option. 
`--foo=bar` | An option and its argument. The option must be able to take arguments. 
`-f` | An option. 
`-abcdef` | Letters are interpreted as options. If one of them can take an argument, the rest of the string is passed to it. 
`--` | The rest of the command-line arguments will be interpreted as positional arguments. 

## Documentation

The tutorial ~~is~~ will be available in the `doc` directory. If argparse was installed using luarocks 2.1.2 or later, it can be viewed using `luarocks doc argparse` command. 

## Testing

argparse comes with a testing suite located in `spec` directory. [busted](http://olivinelabs.com/busted/) is required for testing, it can be installed using luarocks. Run the tests using `busted spec` command from the argparse folder. 
