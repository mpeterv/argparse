local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to actions", function()
   it("calls actions for options", function()
      local action1 = spy.new(function() end)
      local action2 = spy.new(function() end)

      local parser = Parser()
      parser:option "-f" "--from" {
         action = function(...) return action1(...) end
      }
      parser:option "-p" "--pair" {
         action = function(...) return action2(...) end,
         count = "*",
         args = 2
      }

      local args = parser:parse{"-fnowhere", "--pair", "Alice", "Bob", "-p", "Emma", "John"}
      assert.same({from = "nowhere", pair = {{"Alice", "Bob"}, {"Emma", "John"}}}, args)
      assert.spy(action1).called(1)
      assert.spy(action2).called(2)
   end)

   it("properly calls actions for flags", function()
      local action1 = spy.new(function() end)
      local action2 = spy.new(function() end)
      local action3 = spy.new(function() end)

      local parser = Parser()
      parser:flag "-v" "--verbose" {
         action = function(...) return action1(...) end,
         count = "0-3"
      }
      parser:flag "-q" "--quiet" {
         action = function(...) return action2(...) end
      }
      parser:flag "-a" "--another-flag" {
         action = function(...) return action3(...) end
      }

      local args = parser:parse{"-vv", "--quiet"}
      assert.same({verbose = 2, quiet = true}, args)
      assert.spy(action1).called(2)
      assert.spy(action2).called(1)
      assert.spy(action3).called(0)
   end)

   it("calls actions for commands", function()
      local action = spy.new(function() end)

      local parser = Parser "name"
      parser:flag "-v" "--verbose" {
         count = "0-3"
      }
      local add = parser:command "add" {
         action = function(...) return action(...) end
      }
      add:argument "something"

      local args = parser:parse{"add", "me"}
      assert.same({add = true, verbose = 0, something = "me"}, args)
      assert.spy(action).called(1)
   end)
end)
