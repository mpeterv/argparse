local largparse = require "largparse"
local serpent = require "serpent"

local parser = largparse.parser()

parser:argument("input", {
   args = 2
})

parser:flag("-q", "--quiet")
parser:option("-s", "--server")

parser:mutually_exclusive(
   parser:flag("-q", "--quiet"),
   parser:option("-s", "--server")
)

local run = parser:command "run"

run:flag("-f", "--fast")

local args = parser:parse()

print(serpent.block(args))
