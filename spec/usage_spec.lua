local Parser = require "argparse"

describe("tests related to usage message generation", function()
   it("creates correct usage message for empty parser", function()
      local parser = Parser "foo"
         :add_help(false)
      assert.equal(parser:prepare():get_usage(), "Usage: foo")
   end)

   it("creates correct usage message for arguments", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:argument "first"
      parser:argument "second-and-third"
         :args "2"
      parser:argument "maybe-fourth"
         :args "?"
      parser:argument "others"
         :args "*"

      assert.equal(
         [=[Usage: foo <first> <second-and-third> <second-and-third> [<maybe-fourth>] [<others>] ...]=],
         parser:prepare():get_usage()
      )
   end)

   it("creates correct usage message for options", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:flag "-q" "--quiet"
      parser:option "--from"
         :count "1"
         :target "server"
      parser:option "--config"

      assert.equal(
         [=[Usage: foo [-q] --from <server> [--config <config>]]=],
         parser:prepare():get_usage()
      )
   end)

   it("creates correct usage message for commands", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
      run:option "--where"

      assert.equal(
         [=[Usage: foo [-q] [<command>] ...]=],
         parser:prepare():get_usage()
      )
   end)

   it("creates correct usage message for subcommands", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
         :add_help(false)
      run:option "--where"

      parser:prepare()

      assert.equal(
         [=[Usage: foo run [--where <where>]]=],
         run:prepare():get_usage()
      )
   end)

   describe("usage generation can be customized", function()
      it("uses message provided by user", function()
         local parser = Parser "foo"
            :usage "Usage: obvious"
            :add_help(false)
         parser:flag "-q" "--quiet"

         assert.equal(
            [=[Usage: obvious]=],
            parser:prepare():get_usage()
         )
      end)

      it("uses per-option message provided by user", function()
         local parser = Parser "foo"
            :add_help(false)
         parser:flag "-q" "--quiet"
            :usage "[-q | --quiet]"

         assert.equal(
            [=[Usage: foo [-q | --quiet]]=],
            parser:prepare():get_usage()
         )
      end)

      it("uses argnames provided by user", function()
         local parser = Parser "foo"
            :add_help(false)
         parser:argument "inputs"
            :args "1-2"
            :argname "<input>"

         assert.equal(
            [=[Usage: foo <input> [<input>]]=],
            parser:prepare():get_usage()
         )
      end)
   end)
end)
