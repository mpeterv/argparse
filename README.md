# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

__argparse__ is a feature-rich command line parser for Lua inspired by argparse for Python. 

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

Does it have help?

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

##Features

* Declarative and classic interfaces. 

    Declarative: 

    ```lua
    parser:argument "input"
       :description "Path to input file. "
       :convert(io.open)
    parser:option "-v" "--verbose"
       :description "Sets logging level. "
       :count "*"
    ```

    Classic: 

    ```lua
    parser:argument("input", {
       description = "Path to input file. ",
       convert = io.open
    })
    parser:option("-v", "--verbose", {
       description  = "Sets logging level. ",
       count = "*"
    })
    ```

* Parses: 
    * Short options(e.g. `-q`); 
    * Combined short options(e.g. `-zx`); 
    * Short options combined with arguments(e.g. `-I/usr/local/include`); 
    * Long options(e.g. `--quiet`); 
    * Long options with arguments(e.g. `--from there`); 
    * GNU-style long options with arguments(e.g. `--from=there`). 
* Supports named arguments consuming several arguments. 
* Supports options and flags which can be invoked several times, consuming several arguments. 

    ```lua
    parser:option "-p" "--pair"
       :count "*"
       :args(2)

    parser:flag "-v" "--verbose"
       :count "*"

    local args = parser:parse{"--pair", "Alice", "Bob", "-p", "Emma", "John", "-vvv"}
    -- args = {
    --    pair = {
    --       {"Alice", "Bob"},
    --       {"Emma", "John"}
    --    },
    --    verbose = 3
    -- }
    ```

* Supports default values and automatic conversions for arguments. 
* Automatically generates error, usage  and help messages. 
* Supports commands(e.g. in [git](http://git-scm.com/) CLI `add`, `commit`, `push`, etc. are commands). Each command has its own set of options and arguments. 
* Automatically generates hints on typos. 

    ```lua
    parser:option "-f" "--from"
    parser:command "install"

    parser:parse{"--form", "there"}
    -- Error: unknown option '--form'
    -- Did you mean '--from'?

    parser:parse{"isntall"}
    -- Error: unknown command 'isntall'
    -- Did you mean 'install'?
