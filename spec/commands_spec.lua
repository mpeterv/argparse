local argparse = require "argparse"

describe("tests related to commands", function()
   it("handles commands after arguments", function()
      local parser = argparse.parser "name"
      parser:argument "file"
      parser:command "create"
      parser:command "remove"

      local args = parser:parse{"temp.txt", "remove"}
      assert.same({file = "temp.txt", remove = true}, args)
   end)

   it("switches context properly", function()
      local parser = argparse.parser "name"
      local install = parser:command "install"
      install:flag "-q" "--quiet"

      local args = parser:parse{"install", "-q"}
      assert.same({install = true, quiet = true}, args)
      assert.has_error(function() parser:parse{"-q", "install"} end, "unknown option '-q'")
   end)

   it("allows to continue passing old options", function()
      local parser = argparse.parser "name"
      parser:flag "-v" "--verbose" {
         count = "*"
      }
      parser:command "install"

      local args = parser:parse{"-vv", "install", "--verbose"}
      assert.same({install = true, verbose = 3}, args)
   end)

   it("handles nested commands", function()
      local parser = argparse.parser "name"
      local foo = parser:command "foo"
      local bar = foo:command "bar"
      local baz = foo:command "baz"

      local args = parser:parse{"foo", "bar"}
      assert.same({foo = true, bar = true}, args)
   end)

   it("handles no commands depending on parser.require_command", function()
      local parser = argparse.parser "name"
      parser:command "install"

      local args = parser:parse{}
      assert.same({}, args)

      parser:require_command(true)
      assert.has_error(function() parser:parse{} end, "command is required")
   end)

   it("Detects wrong commands", function()
      local parser = argparse.parser "name"
      local install = parser:command "install"

      assert.has_error(function() parser:parse{"run"} end, "unknown command 'run'")
   end)
end)
