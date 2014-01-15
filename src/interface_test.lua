--Just some testing

local MetaParser = require "interface"

local parser = MetaParser "luarocks" {
   description = "a module deployment system for Lua"
}

parser:option "--server" "-s" {
   description = "Fetch rocks/rockspecs from this server"
}

parser:flag "--local" "-l" {
   description = "Use the tree in the user's home directory."
}

local install = parser:command "install" "i"

install:argument "rock"

install:argument "version" {
   args = "?"
}

assert(parser.description == "a module deployment system for Lua")
assert(parser.options[1].name == "--server")
assert(parser.options[1].aliases[1] == "--server")
assert(parser.options[1].aliases[2] == "-s")
assert(parser.options[1].description == "Fetch rocks/rockspecs from this server")
assert(parser.options[1].args == 1)
assert(parser.options[1].count == "?")
assert(parser.options[2].name == "--local")
assert(parser.options[2].args == 0)
assert(parser.commands[1] == install)
assert(install.arguments[1].name == "rock")
assert(install.aliases[2] == "i")
assert(install.arguments[2].name == "version")
assert(install.arguments[2].count == 1)
assert(install.arguments[2].args == "?")
