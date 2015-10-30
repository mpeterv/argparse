local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("actions", function()
   it("for arguments are called", function()
      local parser = Parser()
      local foo
      parser:argument("foo"):action(function(_, _, passed_foo)
         foo = passed_foo
      end)
      local baz
      parser:argument("baz"):args("*"):action(function(_, _, passed_baz)
         baz = passed_baz
      end)

      parser:parse{"a"}
      assert.equals("a", foo)
      assert.same({}, baz)

      parser:parse{"b", "c"}
      assert.equals("b", foo)
      assert.same({"c"}, baz)

      parser:parse{"d", "e", "f"}
      assert.equals("d", foo)
      assert.same({"e", "f"}, baz)
   end)

   it("for options are called", function()
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

   it("for flags are called", function()
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

   it("for options allow custom storing of arguments", function()
      local parser = Parser()
      parser:option("-p --path"):action(function(result, target, argument)
         result[target] = (result[target] or ".") .. "/" .. argument
      end)

      local args = parser:parse{"-pfirst", "--path", "second", "--path=third"}
      assert.same({path = "./first/second/third"}, args)
   end)

   it("for options with several arguments allow custom storing of arguments", function()
      local parser = Parser()
      parser:option("-p --path"):args("*"):action(function(result, target, arguments)
         for _, argument in ipairs(arguments) do
            result[target] = (result[target] or ".") .. "/" .. argument
         end
      end)

      local args = parser:parse{"-p", "first", "second", "third"}
      assert.same({path = "./first/second/third"}, args)
   end)

   it("pass overwrite flag as the fourth argument", function()
      local parser = Parser()
      local overwrites = {}
      parser:flag("-f"):count("0-2"):action(function(_, _, _, overwrite)
         table.insert(overwrites, overwrite)
      end)

      parser:parse{"-ffff"}
      assert.same({false, false, true, true}, overwrites)
   end)

   it("pass user-defined target", function()
      local parser = Parser()
      local target
      parser:flag("-f"):target("force"):action(function(_, passed_target)
         target = passed_target
      end)

      parser:parse{"-f"}
      assert.equals("force", target)
   end)

   it("apply convert before passing arguments", function()
      local parser = Parser()
      local numbers = {}
      parser:option("-n"):convert(tonumber):default("0"):defmode("a"):action(function(_, _, n)
         table.insert(numbers, n)
      end)

      parser:parse{"-n", "-n1", "-n", "-n", "2"}
      assert.same({0, 1, 0, 2}, numbers)
   end)
end)
