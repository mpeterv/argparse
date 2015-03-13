local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to usage message generation", function()
   it("creates correct usage message for empty parser", function()
      local parser = Parser "foo"
         :add_help(false)
      assert.equal(parser:get_usage(), "Usage: foo")
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

      assert.equal([[
Usage: foo <first> <second-and-third> <second-and-third>
       [<maybe-fourth>] [<others>] ...]], parser:get_usage()
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
         [=[Usage: foo [-q] --from <from> [--config <config>]]=],
         parser:get_usage()
      )
   end)

   it("creates correct usage message for options with variable argument count", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:argument "files"
         :args "+"
      parser:flag "-q" "--quiet"
      parser:option "--globals"
         :args "*"

      assert.equal(
         [=[Usage: foo [-q] <files> [<files>] ... [--globals [<globals>] ...]]=],
         parser:get_usage()
      )
   end)

   it("creates correct usage message for arguments with default value", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:argument "input"
         :default "a.in"
      parser:argument "pair"
         :args(2)
         :default "foo"
      parser:argument "pair2"
         :args(2)
         :default "bar"
         :defmode "arg"

      assert.equal(
         [=[Usage: foo [<input>] [<pair> <pair>] [<pair2>] [<pair2>]]=],
         parser:get_usage()
      )
   end)

   it("creates correct usage message for options with default value", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:option "-f" "--from"
         :default "there"
      parser:option "-o" "--output"
         :default "a.out"
         :defmode "arg"

      assert.equal(
         [=[Usage: foo [-f <from>] [-o [<output>]]]=],
         parser:get_usage()
      )
   end)

   it("creates correct usage message for commands", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
      run:option "--where"

      assert.equal(
         [=[Usage: foo [-q] <command> ...]=],
         parser:get_usage()
      )
   end)

   it("creates correct usage message for subcommands", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
         :add_help(false)
      run:option "--where"

      assert.equal(
         [=[Usage: foo run [--where <where>]]=],
         run:get_usage()
      )
   end)

   it("usage messages for commands are correct after several invocations", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
         :add_help(false)
      run:option "--where"

      parser:parse{"run"}
      parser:parse{"run"}

      assert.equal(
         [=[Usage: foo run [--where <where>]]=],
         run:get_usage()
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
            parser:get_usage()
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
            parser:get_usage()
         )
      end)

      it("uses array of argnames provided by user", function()
         local parser = Parser "foo"
            :add_help(false)
         parser:option "--pair"
            :args(2)
            :count "*"
            :argname{"<key>", "<value>"}

         assert.equal(
            [=[Usage: foo [--pair <key> <value>]]=],
            parser:get_usage()
         )
      end)
   end)

   it("creates correct usage message for mutexes", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:mutex(
         parser:flag "-q" "--quiet",
         parser:flag "-v" "--verbose",
         parser:flag "-i" "--interactive"
      )
      parser:mutex(
         parser:flag "-l" "--local",
         parser:option "-f" "--from"
      )
      parser:option "--yet-another-option"

      assert.equal([=[
Usage: foo ([-q] | [-v] | [-i]) ([-l] | [-f <from>])
       [--yet-another-option <yet_another_option>]]=], parser:get_usage()
      )
   end)
end)
