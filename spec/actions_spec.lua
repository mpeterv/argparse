local argparse = require "argparse"

describe("tests related to actions", function()
   it("calls actions for options", function()
      local action1 = spy.new(function(x) end)
      local action2 = spy.new(function(x) end)

      local parser = argparse.parser()
      parser:option "-f" "--from" {
         action = action1
      }
      parser:option "-p" "--pair" {
         action = action2,
         count = "*",
         args = 2
      }

      local args = parser:parse{"-fnowhere", "--pair", "Alice", "Bob", "-p", "Emma", "John"}
      assert.same({from = "nowhere", pair = {{"Alice", "Bob"}, {"Emma", "John"}}}, args)
      assert.spy(action1).called(1)
      assert.spy(action1).called_with("nowhere")
      assert.spy(action2).called(2)
      assert.spy(action2).called_with({"Alice", "Bob"})
      assert.spy(action2).called_with({"Emma", "John"})
   end)

   it("properly calls actions for flags", function()
      local action1 = spy.new(function(x) end)
      local action2 = spy.new(function(x) end)
      local action3 = spy.new(function(x) end)

      local parser = argparse.parser()
      parser:flag "-v" "--verbose" {
         action = action1,
         count = "0-3"
      }
      parser:flag "-q" "--quiet" {
         action = action2
      }
      parser:flag "-a" "--another-flag" {
         action = action3
      }

      local args = parser:parse{"-vv", "--quiet"}
      assert.same({verbose = 2, quiet = true}, args)
      assert.spy(action1).called(2)
      assert.spy(action2).called(1)
      assert.spy(action3).called(0)
   end)

   it("calls actions for arguments", function()
      local action1 = spy.new(function(x) end)
      local action2 = spy.new(function(x) end)

      local parser = argparse.parser()
      parser:argument "input" {
         action = action1
      }
      parser:argument "other" {
         action = action2,
         args = "*"
      }

      local args = parser:parse{"nothing"}
      assert.same({input = "nothing", other = {}}, args)
      assert.spy(action1).called(1)
      assert.spy(action1).called_with("nothing")
      assert.spy(action2).called(1)
      assert.spy(action2).called_with({})
   end)

   it("calls actions for commands", function()
      local action1 = spy.new(function(x) end)
      local action2 = spy.new(function(x) end)

      local parser = argparse.parser "name" {
         action = action1
      }
      parser:flag "-v" "--verbose" {
         count = "0-3"
      }
      local add = parser:command "add" {
         action = action2
      }
      add:argument "something"

      local args = parser:parse{"add", "me"}
      assert.same({add = true, verbose = 0, something = "me"}, args)
      assert.spy(action1).called(1)
      assert.spy(action1).called_with(args)
      assert.spy(action2).called(1)
      assert.spy(action2).called_with(args)
   end)
end)
