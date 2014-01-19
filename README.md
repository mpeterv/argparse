# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

__argparse__ is a feature-rich command line parser for Lua inspired by argparse for Python. 

Not everything stated here is implemented. 

Features: 

* Parses: 
    * Short options(e.g. `-q`); 
    * Combined short options(e.g. `-zx`); 
    * Short options combined with arguments(e.g. `-I/usr/local/include`); 
    * Long options(e.g. `--quiet`); 
    * Long options with arguments(e.g. `--from there); 
    * GNU-style long options with arguments(e.g. `--from=there`). 
* Supports named arguments consuming several arguments. 
* Supports options and flags which can be invoked several times, consuming several arguments. 

    Example: 

    ```lua
    parser:option "-p" "--pair" {
       count = "*",
       args = 2
    }

    parser:flag "-v" "--verbose" {
       count = "*"
    }

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
* [___NYI___] Automatically generates error, help and usage messages. 
* Supports commands(e.g. in [git](http://git-scm.com/) CLI `add`, `commit`, `push`, etc. are commands). Each command has its own set of options and arguments. 
