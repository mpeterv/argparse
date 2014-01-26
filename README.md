# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

__argparse__ is a feature-rich command line parser for Lua inspired by argparse for Python. 

Features: 

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
