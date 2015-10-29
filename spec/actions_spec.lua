local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to actions", function()
   it("calls actions for options", function()
      local action1 = spy.new(function(_, _, arg)
         assert.equal("nowhere", arg)
      end)
      local expected_args = {"Alice", "Bob"}
      local action2 = spy.new(function(_, _, args)
         assert.same(expected_args, args)
         expected_args = {"Emma", "John"}
      end)

      local parser = Parser()
      parser:option "-f" "--from" {
         action = function(...) return action1(...) end
      }
      parser:option "-p" "--pair" {
         action = function(...) return action2(...) end,
         count = "*",
         args = 2
      }

      parser:parse{"-fnowhere", "--pair", "Alice", "Bob", "-p", "Emma", "John"}
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

      parser:parse{"-vv", "--quiet"}
      assert.spy(action1).called(2)
      assert.spy(action2).called(1)
      assert.spy(action3).called(0)
   end)
end)
