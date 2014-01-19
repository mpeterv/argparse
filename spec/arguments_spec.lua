local argparse = require "argparse"

describe("tests related to positional arguments", function()
   describe("passing correct arguments", function()
      it("handles empty parser correctly", function()
         local parser = argparse.parser()
         local args = parser:parse({})
         assert.same(args, {})
      end)

      it("handles one argument correctly", function()
         local parser = argparse.parser()
         parser:argument "foo"
         local args = parser:parse({"bar"})
         assert.same(args, {foo = "bar"})
      end)

      it("handles several arguments correctly", function()
         local parser = argparse.parser()
         parser:argument "foo1"
         parser:argument "foo2"
         local args = parser:parse({"bar", "baz"})
         assert.same(args, {foo1 = "bar", foo2 = "baz"})
      end)

      it("handles multi-argument correctly", function()
         local parser = argparse.parser()
         parser:argument("foo", {
            args = "*"
         })
         local args = parser:parse({"bar", "baz", "qu"})
         assert.same(args, {foo = {"bar", "baz", "qu"}})
      end)

      it("handles restrained multi-argument correctly", function()
         local parser = argparse.parser()
         parser:argument("foo", {
            args = "2-4"
         })
         local args = parser:parse({"bar", "baz"})
         assert.same(args, {foo = {"bar", "baz"}})
      end)

      it("handles several multi-arguments correctly", function()
         local parser = argparse.parser()
         parser:argument("foo1", {
            args = "1-2"
         })
         parser:argument("foo2", {
            args = "*"
         })
         local args = parser:parse({"bar"})
         assert.same(args, {foo1 = {"bar"}, foo2 = {}})
         args = parser:parse({"bar", "baz", "qu"})
         assert.same(args, {foo1 = {"bar", "baz"}, foo2 = {"qu"}})
      end)

      it("handles hyphen correctly", function()
         local parser = argparse.parser()
         parser:argument "foo"
         local args = parser:parse({"-"})
         assert.same(args, {foo = "-"})
      end)

      it("handles double hyphen correctly", function()
         local parser = argparse.parser()
         parser:argument "foo"
         local args = parser:parse({"--", "-q"})
         assert.same(args, {foo = "-q"})
      end)
   end)

   describe("passing incorrect arguments", function()
      it("handles extra arguments with empty parser correctly", function()
         local parser = argparse.parser()

         assert.has_error(function() parser:parse{"foo"} end, "too many arguments")
      end)

      it("handles extra arguments with one argument correctly", function()
         local parser = argparse.parser()
         parser:argument "foo"

         assert.has_error(function() parser:parse{"bar", "baz"} end, "too many arguments")
      end)

      it("handles sudden option correctly", function()
         local parser = argparse.parser()
         parser:argument "foo"

         assert.has_error(function() parser:parse{"-q"} end, "unknown option -q")
      end)

      it("handles too few arguments with one argument correctly", function()
         local parser = argparse.parser()
         parser:argument "foo"

         assert.has_error(function() parser:parse{} end, "too few arguments")
      end)

      it("handles extra arguments with several arguments correctly", function()
         local parser = argparse.parser()
         parser:argument "foo1"
         parser:argument "foo2"

         assert.has_error(function() parser:parse{"bar", "baz", "qu"} end, "too many arguments")
      end)

      it("handles too few arguments with several arguments correctly", function()
         local parser = argparse.parser()
         parser:argument "foo1"
         parser:argument "foo2"

         assert.has_error(function() parser:parse{"bar"} end, "too few arguments")
      end)

      it("handles too few arguments with multi-argument correctly", function()
         local parser = argparse.parser()
         parser:argument "foo" {
            args = "+"
         }
         assert.has_error(function() parser:parse{} end, "too few arguments")
      end)

      it("handles too many arguments with multi-argument correctly", function()
         local parser = argparse.parser()
         parser:argument "foo" {
            args = "2-4"
         }
         assert.has_error(function() parser:parse{"foo", "bar", "baz", "qu", "quu"} end, "too many arguments")
      end)

      it("handles too few arguments with multi-argument correctly", function()
         local parser = argparse.parser()
         parser:argument("foo", {
            args = "2-4"
         })
         assert.has_error(function() parser:parse{"foo"} end, "too few arguments")
      end)

      it("handles too many arguments with several multi-arguments correctly", function()
         local parser = argparse.parser()
         parser:argument("foo1", {
            args = "1-2"
         })
         parser:argument("foo2", {
            args = "0-1"
         })
         assert.has_error(function() parser:parse{"foo", "bar", "baz", "qu"} end, "too many arguments")
      end)

      it("handles too few arguments with several multi-arguments correctly", function()
         local parser = argparse.parser()
         parser:argument("foo1", {
            args = "1-2"
         })
         parser:argument("foo2", {
            args = "*"
         })
         assert.has_error(function() parser:parse{} end, "too few arguments")
      end)
   end)
end)
