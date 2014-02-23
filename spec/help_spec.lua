local Parser = require "argparse"

describe("tests related to help message generation", function()
   it("creates correct help message for empty parser", function()
      local parser = Parser "foo"
      assert.equal(table.concat({
         "Usage: foo [-h]",
         "",
         "Options: ",
         "   -h, --help            Show this help message and exit. "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("does not create extra help options when :prepare is called several times", function()
      local parser = Parser "foo"
      assert.equal(table.concat({
         "Usage: foo [-h]",
         "",
         "Options: ",
         "   -h, --help            Show this help message and exit. "
      }, "\r\n"), parser:prepare():prepare():get_help())
   end)

   it("uses custom help option", function()
      local parser = Parser "foo"
         :add_help {name = "/?"}
      assert.equal(table.concat({
         "Usage: foo [/?]",
         "",
         "Options: ",
         "   /?                    Show this help message and exit. "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("uses description and epilog", function()
      local parser = Parser "foo"
         :description "A description. "
         :epilog "An epilog. "

      assert.equal(table.concat({
         "Usage: foo [-h]",
         "",
         "A description. ",
         "",
         "Options: ",
         "   -h, --help            Show this help message and exit. ",
         "",
         "An epilog. "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("creates correct help message for arguments", function()
      local parser = Parser "foo"
      parser:argument "first"
      parser:argument "second-and-third"
         :args "2"
      parser:argument "maybe-fourth"
         :args "?"
      parser:argument "others"
         :description "Optional. "
         :args "*"

      assert.equal(table.concat({
         "Usage: foo [-h] <first> <second-and-third> <second-and-third>",
         "       [<maybe-fourth>] [<others>] ...",
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
      local parser = Parser "foo"
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

   it("adds margin for multiline descriptions", function()
      local parser = Parser "foo"
      parser:flag "-v"
         :count "0-2"
         :target "verbosity"
         :description [[
Sets verbosity level. 
-v: Report all warnings. 
-vv: Report all debugging information. ]]

      assert.equal(table.concat({
         "Usage: foo [-v] [-h]",
         "",
         "Options: ",
         "   -v                    Sets verbosity level. ",
         "                         -v: Report all warnings. ",
         "                         -vv: Report all debugging information. ",
         "   -h, --help            Show this help message and exit. "
      }, "\r\n"), parser:prepare():get_help())
   end)

   it("creates correct help message for commands", function()
      local parser = Parser "foo"
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
         :description "Run! "
      run:option "--where"

      assert.equal(table.concat({
         "Usage: foo [-q] [-h] <command> ...",
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
      local parser = Parser "foo"
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
      local parser = Parser "foo"
         :help "I don't like your format of help messages"
      parser:flag "-q" "--quiet"

      assert.equal(
         [=[I don't like your format of help messages]=],
         parser:prepare():get_help()
      )
   end)
end)
