local argparse = require "argparse"

describe("tests related to help message generation", function()
   it("creates correct help message for empty parser", function()
      local parser = argparse.parser "foo"
      assert.equal(table.concat({
         "Usage: foo [-h]",
         "",
         "Options: ",
         "   -h, --help            Show this help message and exit. "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("creates correct help message for arguments", function()
      local parser = argparse.parser "foo"
      parser:argument "first"
      parser:argument "second-and-third"
         :args "2"
      parser:argument "maybe-fourth"
         :args "?"
      parser:argument "others"
         :description "Optional. "
         :args "*"

      assert.equal(table.concat({
         "Usage: foo [-h] <first> <second-and-third> <second-and-third> [<maybe-fourth>] [<others>] ...",
         "",
         "Arguments: ",
         "   first",
         "   second-and-third",
         "   maybe-fourth",
         "   others                Optional. ",
         "",
         "Options: ",
         "   -h, --help            Show this help message and exit. "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("creates correct help message for options", function()
      local parser = argparse.parser "foo"
      parser:flag "-q" "--quiet"
      parser:option "--from"
         :count "1"
         :target "server"
      parser:option "--config"

      assert.equal(table.concat({
         "Usage: foo [-q] --from <server> [--config <config>] [-h]",
         "",
         "Options: ",
         "   -q, --quiet",
         "   --from <server>",
         "   --config <config>",
         "   -h, --help            Show this help message and exit. "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("creates correct help message for commands", function()
      local parser = argparse.parser "foo"
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
         :description "Run! "
      run:option "--where"

      assert.equal(table.concat({
         "Usage: foo [-q] [-h] [<command>] ...",
         "",
         "Options: ",
         "   -q, --quiet",
         "   -h, --help            Show this help message and exit. ",
         "",
         "Commands: ",
         "   run                   Run! "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("creates correct help message for subcommands", function()
      local parser = argparse.parser "foo"
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
      run:option "--where"

      parser:prepare()

      assert.equal(table.concat({
         "Usage: foo run [--where <where>] [-h]",
         "",
         "Options: ",
         "   --where <where>",
         "   -h, --help            Show this help message and exit. ",
      }, "\r\n"), run:prepare():get_help())
   end)

   it("uses message provided by user", function()
      local parser = argparse.parser "foo"
         :help "I don't like your format of help messages"
      parser:flag "-q" "--quiet"

      assert.equal(
         [=[I don't like your format of help messages]=],
         parser:prepare():get_help()
      )
   end)
end)
